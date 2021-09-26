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
            (
                "<p>Kondomat <errormorphsyn>juhkkojuvvo<correct>juhkkojuvvojedje</correct><correct>juhkkojuvvojit</correct></errormorphsyn> dehe <errormorphsyn>vuvdojuvvo<correct>vuvdojuvvojedje</correct><correct>vuvdojuvvojit</correct></errormorphsyn> nuoraidvuostáváldimis.</p>",
                [
                    "Kondomat ",
                    "juhkkojuvvo",
                    " dehe ",
                    "vuvdojuvvo",
                    " nuoraidvuostáváldimis.",
                ],
                [
                    [
                        "juhkkojuvvo",
                        9,
                        20,
                        "errormorphsyn",
                        "",
                        ["juhkkojuvvojedje", "juhkkojuvvojit"],
                    ],
                    [
                        "vuvdojuvvo",
                        26,
                        36,
                        "errormorphsyn",
                        "",
                        ["vuvdojuvvojedje", "vuvdojuvvojit"],
                    ],
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


class TestGramTester(unittest.TestCase):
    """Test grammarcheck tester"""

    def setUp(self) -> None:
        self.gram_test = gramcheck_comparator.GramTest()
        return super().setUp()

    @parameterized.expand(
        [
            (["c", 3, 6, "", "", []], ["", 3, 6, "double-space-before", "", []], True),
            (["c", 3, 6, "", "", []], ["", 2, 5, "double-space-before", "", []], False),
            (["c", 3, 6, "errorsyn", "", []], ["d", 3, 6, "msyn", "", []], False),
            (["c", 3, 6, "errorsyn", "", []], ["c", 2, 6, "msyn", "", []], False),
            (["c", 3, 6, "errorsyn", "", []], ["c", 3, 5, "msyn", "", []], False),
            (["c", 3, 6, "errorsyn", "", []], ["c", 3, 6, "msyn", "", []], True),
        ]
    )
    def test_same_range_and_error(self, c_error, d_error, expected_boolean):
        self.assertTrue(
            self.gram_test.has_same_range_and_error(c_error, d_error)
            == expected_boolean,
        )

    @parameterized.expand(
        [
            (["c", 3, 6, "", "", []], ["", 3, 6, "double-space-before", "", []], False),
            (
                ["c", 3, 6, "", "", ["b"]],
                ["c", 3, 6, "double-space-before", "", ["a"]],
                False,
            ),
            (["c", 3, 6, "errorsyn", "", []], ["c", 3, 6, "msyn", "", []], False),
            (
                ["c", 3, 6, "errorsyn", "", ["a"]],
                ["c", 3, 6, "msyn", "", ["a", "b"]],
                True,
            ),
        ]
    )
    def test_suggestion_with_hits(self, c_error, d_error, expected_boolean):
        self.assertEqual(
            self.gram_test.has_suggestions_with_hit(c_error, d_error), expected_boolean
        )

    @parameterized.expand(
        [
            (["c", 3, 6, "", "", ["b"]], ["c", 3, 6, "", "", ["b"]], False),
            (["c", 3, 6, "", "", ["b"]], ["c", 3, 6, "", "", []], True),
        ]
    )
    def test_has_no_suggesions(self, c_error, d_error, expected_boolean):
        self.assertEqual(
            self.gram_test.has_no_suggestions(c_error, d_error), expected_boolean
        )
