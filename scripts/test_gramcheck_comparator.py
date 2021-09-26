"""Test grammarcheck tester functionality"""
import unittest
import gramcheck_comparator
from parameterized import parameterized
from lxml import etree


class TestGramChecker(unittest.TestCase):
    """Test grammarcheck tester"""

    def setUp(self) -> None:
        self.gram_checker = gramcheck_comparator.GramChecker()
        return super().setUp()

    @parameterized.expand(
        [
            (
                '<p>Mun lean <errorort>sjievnnjis<correct errorinfo="conc,vnn-vnnj">sjievnnijis</correct></errorort></p>',
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
                "<p><errormorphsyn>Nieiddat leat nuorra"
                '<correct errorinfo="a,spred,nompl,nomsg,agr">Nieiddat leat nuorat</correct>'
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
                "<errorort>Nordkjosbotn ii<correct>Nordkjosbotnii</correct></errorort> "
                "(mii lea ge "
                "<errorort>nordkjosbotn<correct>Nordkjosbotn</correct></errorort> "
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
                "<p>"
                "<errormorphsyn>"
                "<errorort>"
                "šaddai"
                '<correct errorinfo="verb,conc">šattai</correct>'
                "</errorort> ollu áššit"
                '<correct errorinfo="verb,fin,pl3prs,sg3prs,tense">šadde ollu áššit</correct>'
                "</errormorphsyn></p>",
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
                "<p>a "
                "<errorformat>"
                "b  c"
                '<correct errorinfo="notspace">b c</correct>'
                "</errorformat>"
                " d.</p>",
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
                "<p>"
                "<errormorphsyn>"
                "<errorort>"
                "šaddai"
                '<correct errorinfo="verb,conc">šattai</correct>'
                "</errorort> ollu áššit"
                '<correct errorinfo="verb,fin,pl3prs,sg3prs,tense">šadde ollu áššit</correct>'
                "</errormorphsyn></p>",
                "<p>"
                "<errormorphsyn>"
                "šattai ollu áššit"
                '<correct errorinfo="verb,fin,pl3prs,sg3prs,tense">šadde ollu áššit</correct>'
                "</errormorphsyn></p>",
            )
        ]
    )
    def test_correct_lowest_level(self, para, wanted):
        corrected = self.gram_checker.correct_lowest_level(etree.fromstring(para))
        self.assertEqual(etree.tostring(corrected, encoding="unicode"), wanted)

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
