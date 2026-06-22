# bash

Maintains an opinionated extended toolset for the bash terminal.

## Usage

```bash
mv bash_aliases ~/.bash_aliases
mv bash_functions ~/.bash_functions

cat << 'EOF' >> ~/.bashrc

# Load custom aliases and functions if they exist
if [ -f ~/.bash_aliases ]; then . ~/.bash_aliases; fi
if [ -f ~/.bash_functions ]; then . ~/.bash_functions; fi
EOF
```
