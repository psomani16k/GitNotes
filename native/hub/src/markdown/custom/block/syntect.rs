//! Syntax highlighting for code blocks
use rinf::debug_print;
use syntect::highlighting::ThemeSet;
use syntect::html::highlighted_html_for_string;
use syntect::parsing::SyntaxSet;

use markdown_it::parser::core::CoreRule;
use markdown_it::parser::extset::MarkdownItExt;
use markdown_it::plugins::cmark::block::code::CodeBlock;
use markdown_it::plugins::cmark::block::fence::CodeFence;
use markdown_it::{MarkdownIt, Node, NodeValue, Renderer};

#[derive(Debug)]
pub struct SyntectSnippet {
    pub html: String,
}

impl NodeValue for SyntectSnippet {
    fn render(&self, _: &Node, fmt: &mut dyn Renderer) {
        let cleaned_html = self
            .html
            .replace(r#"style="background-color:#ffffff;""#, "");
        fmt.text_raw(&cleaned_html);
    }
}

#[derive(Debug, Clone, Copy)]
struct SyntectSettings(&'static str);
impl MarkdownItExt for SyntectSettings {}

impl Default for SyntectSettings {
    fn default() -> Self {
        Self("InspiredGitHub")
    }
}

pub fn add(md: &mut MarkdownIt) {
    md.add_rule::<SyntectRule>();
}

pub fn set_theme(md: &mut MarkdownIt, theme: &'static str) {
    md.ext.insert(SyntectSettings(theme));
}

pub struct SyntectRule;
impl CoreRule for SyntectRule {
    fn run(root: &mut Node, md: &MarkdownIt) {
        let ss = SyntaxSet::load_defaults_newlines();
        let ts = ThemeSet::load_defaults();
        // let themes_iter = ts.themes.iter();
        // themes_iter.for_each(|(name, _)| {
        //     debug_print!("Theme ----> {name}");
        // });
        let theme = &ts.themes[md
            .ext
            .get::<SyntectSettings>()
            .copied()
            .unwrap_or_default()
            .0];

        root.walk_mut(|node, _| {
            let mut content = None;
            let mut language = None;

            if let Some(data) = node.cast::<CodeBlock>() {
                content = Some(&data.content);
            } else if let Some(data) = node.cast::<CodeFence>() {
                language = Some(data.info.clone());
                content = Some(&data.content);
            }

            if let Some(content) = content {
                let mut syntax = None;
                if let Some(language) = language {
                    // if its a mermad block, skip modifying it
                    if language.trim() == "mermaid" {
                        return;
                    }
                    syntax = ss.find_syntax_by_token(&language);
                }
                let syntax = syntax.unwrap_or_else(|| ss.find_syntax_plain_text());

                let html = highlighted_html_for_string(content, &ss, syntax, theme);

                if let Ok(html) = html {
                    node.replace(SyntectSnippet { html });
                }
            }
        });
    }
}
