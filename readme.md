# async-tags

This is a simple implementation of an async tag builder using
ctags and Neovim builtin libuv. This is just a pet project to
try and learn more about Neovim async processess, if you are
interested on automatically re-building your tags, take a look
at [tpope's suggestion](https://tbaggery.com/2011/08/08/effortless-ctags-with-git.html)
using git hooks, although it will require more configuration
(creating hooks for each repo and merging with any existing
hooks).

If you are also interested in learning more about libuv, check
the [docs](https://github.com/luvit/luv/blob/master/docs.md#uvspawnfile-options-onexit).

I don't plan on writing any docs for now, in the future I might
try to setup some sort of automatic doc generator, but it's not
likely, however the code should be readable and it's below 100
lines at the time of this writing.
