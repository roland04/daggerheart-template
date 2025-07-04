function Image(el)
    el.caption = {}
    el.attributes["width"] = "1.0\\linewidth"
    el.attributes["height"] = nil
    return {
        pandoc.RawInline('latex', '\\vspace{0.5em}'),
        pandoc.RawInline('latex', '{\\centering '),
        el,
        pandoc.RawInline('latex', '\\par}'),
        pandoc.RawInline('latex', '\\vspace{0.5em}')
    }
end
