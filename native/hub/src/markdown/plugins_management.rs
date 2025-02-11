use super::custom::{block, inline};
use markdown_it::plugins::{cmark, extra, html, sourcepos};

pub(crate) fn add_plugins(parser: &mut markdown_it::MarkdownIt) {
    // PREDEFINED PLUGINS

    // cmark - omitted cmark::link
    cmark::inline::newline::add(parser);
    cmark::inline::escape::add(parser);
    cmark::inline::backticks::add(parser);
    cmark::inline::emphasis::add(parser);
    cmark::inline::autolink::add(parser);
    cmark::inline::image::add(parser);
    cmark::inline::entity::add(parser);
    cmark::block::code::add(parser);
    cmark::block::fence::add(parser);
    cmark::block::blockquote::add(parser);
    cmark::block::hr::add(parser);
    cmark::block::list::add(parser);
    cmark::block::reference::add(parser);
    cmark::block::heading::add(parser);
    cmark::block::lheading::add(parser);
    cmark::block::paragraph::add(parser);

    // extra - omitted extra::syntect, extra::heading_anchors, extra::beautify_links
    extra::strikethrough::add(parser);
    extra::linkify::add(parser);
    extra::tables::add(parser);
    extra::typographer::add(parser);
    extra::smartquotes::add(parser);

    // html
    html::add(parser);

    // source pos for tasklist manipulation
    sourcepos::add(parser);

    // CUSTOM PLUGINS

    // task list plugin for checkboxes with callback to GitNotes
    block::task_list::add(parser);
    // link plugins for links with callback to GitNotes
    inline::link::add(parser);
}
