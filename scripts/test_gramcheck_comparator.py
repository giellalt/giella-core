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
                    [
                        "sjievnnjis",
                        9,
                        19,
                        "errorort",
                        "conc,vnn-vnnj",
                        ["sjievnnijis"],
                    ]
                ],
            ),
            (
                '<p><errormorphsyn correct="Nieiddat leat nuorat" '
                'errorinfo="a,spred,nompl,nomsg,agr">Nieiddat leat nuorra'
                "</errormorphsyn></p>",
                ["Nieiddat leat nuorra"],
                [
                    [
                        "Nieiddat leat nuorra",
                        0,
                        20,
                        "errormorphsyn",
                        "a,spred,nompl,nomsg,agr",
                        ["Nieiddat leat nuorat"],
                    ]
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
                    [
                        "Nordkjosbotn ii",
                        6,
                        21,
                        "errorort",
                        "",
                        ["Nordkjosbotnii"],
                    ],
                    [
                        "nordkjosbotn",
                        34,
                        46,
                        "errorort",
                        "",
                        ["Nordkjosbotn"],
                    ],
                ],
            ),
            (
                '<p><errormorphsyn correct="šadde ollu áššit" '
                'errorinfo="verb,fin,pl3prs,sg3prs,tense"><errorort correct="šattai" errorinfo="verb,conc">'
                "šaddai</errorort> ollu áššit</errormorphsyn></p>",
                ["šaddai", " ollu áššit"],
                [
                    [
                        "šaddai",
                        0,
                        6,
                        "errorort",
                        "verb,conc",
                        ["šattai"],
                    ]
                ],
            ),
            (
                '<p>a <errorformat correct="b c" errorinfo="notspace">b  c</errorformat> d.</p>',
                ["a ", "b  c", " d."],
                [["b  c", 2, 6, "errorformat", "notspace", ["b c"]]],
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

    @parameterized.expand(
        [
            (
                [["b  c", 2, 6, "errorformat", "notspace", ["b c"]]],
                [["c", 3, 6, "errorformat", "notspace", ["b c"]]],
            )
        ]
    )
    def test_normalise_error_markup(self, errors, wanted_errors):
        self.gram_checker.normalise_error_markup(errors)
        self.assertListEqual(errors, wanted_errors)
