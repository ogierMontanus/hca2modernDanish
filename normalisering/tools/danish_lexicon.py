#!/usr/bin/env python3
"""
danish_lexicon.py - thin, cached wrapper over the modern Danish DDO Hunspell
dictionary (ordbøger/aaTilÅ/ddo_DDO.{dic,aff}) via the pure-Python `spylls`
engine.

Accepts either a Hunspell pair (path prefix, or a .dic/.aff file) or a plain
newline word list, so tests can run without spylls installed.

    lex = DanishLexicon.load("ordbøger/aaTilÅ/ddo_DDO")
    lex.known("kvinde")        # True
    lex.known("rel")           # False
    lex.suggest("rel")         # ['ler', 're', 'reel', ...]
"""
from __future__ import annotations

import functools
from pathlib import Path


class DanishLexicon:
    def __init__(self, dictionary=None, wordset: set[str] | None = None):
        self._dict = dictionary          # spylls Dictionary or None
        self._wordset = wordset          # plain word list fallback

    @classmethod
    def load(cls, path: str | Path) -> "DanishLexicon":
        p = Path(path)
        prefix = p.with_suffix("") if p.suffix in (".dic", ".aff") else p
        if Path(str(prefix) + ".dic").exists():
            from spylls.hunspell import Dictionary           # lazy import
            return cls(dictionary=Dictionary.from_files(str(prefix)))
        # plain word-list fallback
        words = {l.strip() for l in p.read_text(encoding="utf-8").splitlines()
                 if l.strip() and not l.startswith("#")}
        return cls(wordset=words)

    @functools.lru_cache(maxsize=200_000)
    def known(self, word: str) -> bool:
        if self._dict is not None:
            return bool(self._dict.lookup(word))
        return word in self._wordset

    def suggest(self, word: str, limit: int = 8) -> list[str]:
        if self._dict is not None:
            return list(self._dict.suggest(word))[:limit]
        return []


if __name__ == "__main__":
    import sys
    lex = DanishLexicon.load(sys.argv[1])
    for w in sys.argv[2:]:
        print(f"{w}\tknown={lex.known(w)}\tsuggest={lex.suggest(w, 5)}")
