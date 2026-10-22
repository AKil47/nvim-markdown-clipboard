use std::io;

use arboard::Clipboard;
use mlua::{Lua, Result, Table};
use pulldown_cmark::{html, Options, Parser};

#[mlua::lua_module]
fn nvim_markdown_clipboard(lua: &Lua) -> Result<Table> {
    let exports = lua.create_table()?;
    exports.set(
        "copy",
        lua.create_function(|_, markdown: String| {
            Clipboard::new()
                .and_then(|mut clipboard| {
                    clipboard.set_html(markdown_to_html(&markdown), Some(markdown))
                })
                .map_err(mlua::Error::external)
        })?,
    )?;
    exports.set(
        "paste",
        lua.create_function(|_, ()| {
            let html = Clipboard::new()
                .and_then(|mut clipboard| clipboard.get().html())
                .map_err(mlua::Error::external)?;
            html_to_markdown(&html).map_err(mlua::Error::external)
        })?,
    )?;
    Ok(exports)
}

fn markdown_to_html(markdown: &str) -> String {
    let options =
        Options::ENABLE_TABLES | Options::ENABLE_STRIKETHROUGH | Options::ENABLE_TASKLISTS;
    let mut rendered = String::new();
    html::push_html(&mut rendered, Parser::new_ext(markdown, options));
    rendered
}

fn html_to_markdown(html: &str) -> io::Result<String> {
    htmd::convert(html)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn markdown_links_render_as_html() {
        assert_eq!(
            markdown_to_html("A [link](https://example.com)"),
            "<p>A <a href=\"https://example.com\">link</a></p>\n"
        );
    }

    #[test]
    fn html_links_become_markdown() {
        assert_eq!(
            html_to_markdown("<a href=\"https://example.com\">link</a>").unwrap(),
            "[link](https://example.com)"
        );
    }
}
