use markdown_it::{parser::block::BlockRule, Node, NodeValue};
use rinf::debug_print;

use crate::messages::markdown::{ProcessMarkdown, ProcessMarkdownCallback};

pub async fn handle_markdown() {
    let mut recv = ProcessMarkdown::get_dart_signal_receiver().unwrap();
    while let Some(message) = recv.recv().await {
        let md = message.message.markdown_data;
        let html = process_markdown(md);
        let html_split = html.split("\n");
        for i in html_split {
            debug_print!("---> {}", i);
        }
        ProcessMarkdownCallback { html_data: html }.send_signal_to_dart();
    }
}

fn process_markdown(md: String) -> String {
    let mut parser = markdown_it::MarkdownIt::new();
    markdown_it::plugins::cmark::add(&mut parser);
    // markdown_it::plugins::extra::add(&mut parser);
    markdown_it::plugins::extra::strikethrough::add(&mut parser);
    markdown_it::plugins::extra::beautify_links::add(&mut parser);
    markdown_it::plugins::extra::linkify::add(&mut parser);
    markdown_it::plugins::extra::tables::add(&mut parser);
    // markdown_it::plugins::extra::syntect::add(&mut parser);
    markdown_it::plugins::extra::typographer::add(&mut parser);
    markdown_it::plugins::extra::smartquotes::add(&mut parser);
    markdown_it::plugins::html::add(&mut parser);
    markdown_it_tasklist::add(&mut parser);
    parser.block.add_rule::<KatexBlockRule>();
    let ast = parser.parse(&md);
    return ast.render();
}

#[derive(Debug)]
/// For processing katex blocks
struct KatexBlock {
    content: String,
}

impl KatexBlock {
    pub fn new(katex_content: String) -> Self {
        return KatexBlock {
            content: katex_content,
        };
    }
}

impl NodeValue for KatexBlock {
    fn render(&self, node: &markdown_it::Node, fmt: &mut dyn markdown_it::Renderer) {
        fmt.cr();
        fmt.open("div", &[]);
        fmt.text_raw(&self.content);
        fmt.close("div");
        fmt.cr();
    }
}

/// For processing katex blocks
struct KatexBlockRule;

impl BlockRule for KatexBlockRule {
    fn run(
        state: &mut markdown_it::parser::block::BlockState,
    ) -> Option<(markdown_it::Node, usize)> {
        // get contents of a line number `state.line` and check it
        let line = state.get_line(state.line).trim();

        // if the block is of only one line eg: $$ c = \lambda \cdot f $$
        if line.starts_with("$$") && line.ends_with("$$") && line.len() > 4 {
            let line = line.to_string();
            let len = line.len();
            let line = line[2..(len - 2)].to_string();
            let line = format!("$% {} %$", line);
            let node = KatexBlock::new(line);
            let node = Node::new(node);
            return Some((node, 1));
        }

        // if the block is of multiple lines eg:
        // $$
        // c = \lambda \cdot f
        // $$
        if line.starts_with("$$") {
            let start = state.line;
            let mut next_line = state.line + 1;
            while !state.get_line(next_line).ends_with("$$") {
                if next_line > state.line_max {
                    return None;
                }
                next_line += 1;
            }
            let end = next_line;

            let (content, _) = state.get_lines(start, end + 1, 0, true);
            let content = content.trim();
            let content = content[2..content.len() - 2].to_string();

            let content = format!("%$ {} $%", content);
            let node = KatexBlock::new(content);
            let node = Node::new(node);
            return Some((node, end - start + 1));
        }

        // Some((Node::new(), 1))
        None
    }
}
