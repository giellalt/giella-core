"""Test grammarcheck tester functionality"""
import unittest
import gramcheck_comparator
from parameterized import parameterized
from lxml import etree


class TestErrorMarkup(unittest.TestCase):
    """Test grammarcheck tester"""

    def setUp(self) -> None:
        self.gram_checker = gramcheck_comparator.GramChecker()
        return super().setUp()

    @parameterized.expand(
        [
            (
                '<p>Mun lean <errorort correct="sjievnnijis" errorinfo="conc,vnn-vnnj">sjievnnjis</errorort></p>',
                ["Mun lean ", "sjievnnjis"],
                [
                    {
                        "correct": "sjievnnijis",
                        "end": 19,
                        "error": "sjievnnjis",
                        "errorinfo": "conc,vnn-vnnj",
                        "start": 9,
                        "type": "errorort",
                    }
                ],
            ),
            (
                '<p><errormorphsyn correct="Nieiddat leat nuorat" '
                'errorinfo="a,spred,nompl,nomsg,agr">Nieiddat leat nuorra'
                "</errormorphsyn></p>",
                ["Nieiddat leat nuorra"],
                [
                    {
                        "correct": "Nieiddat leat nuorat",
                        "end": 20,
                        "error": "Nieiddat leat nuorra",
                        "errorinfo": "a,spred,nompl,nomsg,agr",
                        "start": 0,
                        "type": "errormorphsyn",
                    }
                ],
            ),
            (
                "<p>gitta "
                '<errorort correct="Nordkjosbotnii">Nordkjosbotn ii</errorort> '
                "(mii lea ge "
                '<errorort correct="Nordkjosbotn">nordkjosbotn</errorort> '
                "sámegillii? Muhtin, veahket mu!) gos</p>",
                [
                    "gitta ",
                    "Nordkjosbotn ii",
                    " (mii lea ge ",
                    "nordkjosbotn",
                    " sámegillii? Muhtin, veahket mu!) gos",
                ],
                [
                    {
                        "correct": "Nordkjosbotnii",
                        "end": 21,
                        "error": "Nordkjosbotn ii",
                        "start": 6,
                        "type": "errorort",
                    },
                    {
                        "correct": "Nordkjosbotn",
                        "end": 46,
                        "error": "nordkjosbotn",
                        "start": 34,
                        "type": "errorort",
                    },
                ],
            ),
            (
                '<p><errormorphsyn correct="šadde ollu áššit" '
                'errorinfo="verb,fin,pl3prs,sg3prs,tense"><errorort correct="šattai" errorinfo="verb,conc">'
                "šaddai</errorort> ollu áššit</errormorphsyn></p>",
                ["šaddai", " ollu áššit"],
                [
                    {
                        "correct": "šattai",
                        "end": 6,
                        "error": "šaddai",
                        "errorinfo": "verb,conc",
                        "start": 0,
                        "type": "errorort",
                    }
                ],
            ),
        ]
    )
    def test_extract_error_info(self, paragraph, want_parts, want_errors):
        parts = []
        errors = []
        self.gram_checker.extract_error_info(parts, errors, etree.fromstring(paragraph))

        self.assertListEqual(parts, want_parts)
        self.assertListEqual(
            errors,
            want_errors,
        )
