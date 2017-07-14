# Prompt for the [powerlevel9k zsh theme](https://github.com/bhilburn/powerlevel9k)

Credit for shrink_path goes to [Daniel Friesel](https://github.com/robbyrussell/oh-my-zsh/tree/master/plugins/shrink-path)

![](https://raw.githubusercontent.com/bandresen/p9k_prompt_colordir/master/screenshot.png)

## Installation

Use a plugin manager for zsh, for example Zplugin

```bash
zplugin load bandresen/p9k_prompt_colordir
```

## Configuration

Add `colordir colorbase_joined` to for example
`POWERLEVEL9K_LEFT_PROMPT_ELEMENTS`

```bash
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(... colordir colorbase_joined ...)
```
