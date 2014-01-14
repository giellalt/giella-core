use Test::XML::Twig tests => 35;
use Test::More;
use strict;
use warnings;
use utf8;
use Getopt::Long;

use langTools::Corpus qw(add_error_markup);

#
# Load the modules we are testing
#
BEGIN {
    use_ok('langTools::Corpus');
}
require_ok('langTools::Corpus');

my $debug = 0;
GetOptions( "debug" => \$debug );
$langTools::Corpus::test = $debug;

sub test_add_error_markup {
    my %question_answer = (
        '<p>jne.$(adv,typo|jna.)</p>' =>
    '<p><errorort correct="jna." errtype="typo" pos="adv">jne.</errorort></p>',

        '<p>daesn\'$daesnie</p>' =>
        '<p><errorort correct="daesnie">daesn\'</errorort></p>',

        '<p>1]§Ij</p>' => '<p><error correct="Ij">1]</error></p>',

        '<p>væ]keles§(væjkeles)</p>' =>
        '<p><error correct="væjkeles">væ]keles</error></p>',

        '<p>smávi-§smávit-</p>' =>
        '<p><error correct="smávit-">smávi-</error></p>',

        '<p>CD:t§CD:at</p>' => '<p><error correct="CD:at">CD:t</error></p>',

        '<p>DNB-feaskáris§(DnB-feaskáris)</p>' =>
        '<p><error correct="DnB-feaskáris">DNB-feaskáris</error></p>',

        '<p>boade§boađe</p>' => '<p><error correct="boađe">boade</error></p>',

        '<p>2005’as§2005:s</p>' =>
        '<p><error correct="2005:s">2005’as</error></p>',

        '<p>NSRii§NSR:ii</p>' => '<p><error correct="NSR:ii">NSRii</error></p>',

        '<p>Nordkjosbotn\'ii§Nordkjosbotnii</p>' =>
        '<p><error correct="Nordkjosbotnii">Nordkjosbotn\'ii</error></p>',

        '<p>nourra$(a,meta|nuorra)</p>' =>
    '<p><errorort correct="nuorra" errtype="meta" pos="a">nourra</errorort></p>',

    '<p>(Nieiddat leat nuorra)£(a,spred,nompl,nomsg,agr|Nieiddat leat nuorat)</p>'
        => '<p><errormorphsyn cat="nompl" const="spred" correct="Nieiddat leat nuorat" errtype="agr" orig="nomsg" pos="a">Nieiddat leat nuorra</errormorphsyn></p>',

        '<p>(riŋgen nieidda lusa)¥(x,pph|riŋgen niidii)</p>' =>
    '<p><errorsyn correct="riŋgen niidii" errtype="pph" pos="x">riŋgen nieidda lusa</errorsyn></p>',

        '<p>ovtta¥(num,redun| )</p>' =>
        '<p><errorsyn correct=" " errtype="redun" pos="num">ovtta</errorsyn></p>',

        '<p>dábálaš€(adv,adj,der|dábálaččat)</p>' =>
    '<p><errorlex correct="dábálaččat" errtype="der" origpos="adj" pos="adv">dábálaš</errorlex></p>',

        '<p>ráhččamušaid¢(noun,mix|rahčamušaid)</p>' =>
    '<p><errorortreal pos="noun" errtype="mix" correct="rahčamušaid">ráhččamušaid</errorortreal></p>',

    '<p>gitta Nordkjosbotn\'ii$Nordkjosbotnii (mii lea ge nordkjosbotn$Nordkjosbotn sámegillii? Muhtin, veahket mu!) gos</p>'
        => '<p>gitta <errorort correct="Nordkjosbotnii">Nordkjosbotn\'ii</errorort> (mii lea ge <errorort correct="Nordkjosbotn">nordkjosbotn</errorort> sámegillii? Muhtin, veahket mu!) gos</p>',

    '<p>Čáppa muohtaskulptuvrraid ráhkadeapmi VSM olggobealde lei maiddái ovttasbargu gaskal (skuvla ohppiid)£(noun,attr,gensg,nomsg,case|skuvlla ohppiid) ja VSM.</p>'
        => '<p>Čáppa muohtaskulptuvrraid ráhkadeapmi VSM olggobealde lei maiddái ovttasbargu gaskal <errormorphsyn cat="gensg" const="attr" correct="skuvlla ohppiid" errtype="case" orig="nomsg" pos="noun">skuvla ohppiid</errormorphsyn> ja VSM.</p>',

        '<p>- ruksesruonáčalmmehisvuohta lea sullii 8%:as$(acr,suf|8%:s)</p>' =>
    '<p>- ruksesruonáčalmmehisvuohta lea sullii <errorort correct="8%:s" errtype="suf" pos="acr">8%:as</errorort></p>',

        '<p>( nissonin¢(noun,suf|nissoniin) dušše (0.6 %:s)£(0.6 %) )</p>' =>
    '<p>( <errorortreal correct="nissoniin" errtype="suf" pos="noun">nissonin</errorortreal> dušše <errormorphsyn correct="0.6 %">0.6 %:s</errormorphsyn> )</p>',

    '<p>(haploida) ja njiŋŋalas$(noun,á|njiŋŋálas) ságahuvvon$(verb,a|sagahuvvon) manneseallas (diploida)</p>'
        => '<p>(haploida) ja <errorort correct="njiŋŋálas" errtype="á" pos="noun">njiŋŋalas</errorort> <errorort correct="sagahuvvon" errtype="a" pos="verb">ságahuvvon</errorort> manneseallas (diploida)</p>',

    '<p>(gii oahpaha) giinu$(x,notcmp|gii nu) manai intiánalávlagat$(loan,conc|indiánalávlagat) (guovža-klána)$(noun,cmp|guovžaklána) olbmuid</p>'
        => '<p>(gii oahpaha) <errorort correct="gii nu" errtype="notcmp" pos="x">giinu</errorort> manai <errorort correct="indiánalávlagat" errtype="conc" pos="loan">intiánalávlagat</errorort> <errorort correct="guovžaklána" errtype="cmp" pos="noun">guovža-klána</errorort> olbmuid</p>',

    '<p>I 1864 ga han ut boka <span type="quote" xml:lang="swe">"Fornuftigt Madstel"</span>. Asbjørsen$(prop,typo|Asbjørnsen) døde 5. januar 1885, nesten 73 år gammel.</p>'
        => '<p>I 1864 ga han ut boka <span type="quote" xml:lang="swe">"Fornuftigt Madstel"</span>. <errorort correct="Asbjørnsen" errtype="typo" pos="prop">Asbjørsen</errorort> døde 5. januar 1885, nesten 73 år gammel.</p>',

        #Nested markup
    '<p>(šaddai$(verb,conc|šattai) ollu áššit)£(verb,fin,pl3prs,sg3prs,tense|šadde ollu áššit)</p>'
        => '<p><errormorphsyn cat="pl3prs" const="fin" correct="šadde ollu áššit" errtype="tense" orig="sg3prs" pos="verb"><errorort correct="šattai" errtype="conc" pos="verb">šaddai</errorort> ollu áššit</errormorphsyn></p>',

    '<p>(guokte ganddat§(n,á|gánddat))£(n,nump,gensg,nompl,case|guokte gándda)</p>'
        => '<p><errormorphsyn cat="gensg" const="nump" correct="guokte gándda" errtype="case" orig="nompl" pos="n">guokte <error correct="gánddat">ganddat</error></errormorphsyn></p>',

    '<p>(Nieiddat leat nourra$(adj,meta|nuorra))£(adj,spred,nompl,nomsg,agr|Nieiddat leat nuorat)</p>'
        => '<p><errormorphsyn cat="nompl" const="spred" correct="Nieiddat leat nuorat" errtype="agr" orig="nomsg" pos="adj">Nieiddat leat <errorort correct="nuorra" errtype="meta" pos="adj">nourra</errorort></errormorphsyn></p>',

    '<p>(leat (okta máná)£(n,spred,nomsg,gensg,case|okta mánná))£(v,v,sg3prs,pl3prs,agr|lea okta mánná)</p>'
        => '<p><errormorphsyn cat="sg3prs" const="v" correct="lea okta mánná" errtype="agr" orig="pl3prs" pos="v">leat <errormorphsyn cat="nomsg" const="spred" correct="okta mánná" errtype="case" orig="gensg" pos="n">okta máná</errormorphsyn></errormorphsyn></p>',

    '<p>heaitit dáhkaluddame$(verb,a|dahkaluddame) ahte sis máhkaš¢(adv,á|mahkáš) livččii makkarge$(adv,á|makkárge) politihkka, muhto rahpasit baicca muitalivčče (makkar$(interr,á|makkár) soga)€(man soga) sii ovddasttit$(verb,conc|ovddastit).</p>'
        => '<p>heaitit <errorort correct="dahkaluddame" errtype="a" pos="verb">dáhkaluddame</errorort> ahte sis <errorortreal correct="mahkáš" errtype="á" pos="adv">máhkaš</errorortreal> livččii <errorort correct="makkárge" errtype="á" pos="adv">makkarge</errorort> politihkka, muhto rahpasit baicca muitalivčče <errorlex correct="man soga"><errorort correct="makkár" errtype="á" pos="interr">makkar</errorort> soga</errorlex> sii <errorort correct="ovddastit" errtype="conc" pos="verb">ovddasttit</errorort>.</p>',

    '<p>(Bearpmahat$(noun,svow|Bearpmehat) earuha€(verb,v,w|sirre))£(verb,fin,pl3prs,sg3prs,agr|Bearpmehat sirrejit) uskki ja loaiddu.</p>'
        => '<p><errormorphsyn cat="pl3prs" const="fin" correct="Bearpmehat sirrejit" errtype="agr" orig="sg3prs" pos="verb"><errorort correct="Bearpmehat" errtype="svow" pos="noun">Bearpmahat</errorort> <errorlex correct="sirre" errtype="w" origpos="v" pos="verb">earuha</errorlex></errormorphsyn> uskki ja loaiddu.</p>',

    '<p>Mirja ja Line leaba (gulahallan olbmožat)¢(noun,cmp|gulahallanolbmožat)€gulahallanolbmot</p>'
        => '<p>Mirja ja Line leaba <errorlex correct="gulahallanolbmot"><errorortreal correct="gulahallanolbmožat" errtype="cmp" pos="noun">gulahallan olbmožat</errorortreal></errorlex></p>',

    '<p>(Ovddit geasis)£(noun,advl,gensg,locsg,case|Ovddit geasi) ((čoaggen$(verb,mono|čoggen) ollu jokŋat)£(noun,obj,genpl,nompl,case|čoggen ollu joŋaid) ja sarridat)£(noun,obj,genpl,nompl,case|čoggen ollu joŋaid ja sarridiid)</p>'
        => '<p><errormorphsyn cat="gensg" const="advl" correct="Ovddit geasi" errtype="case" orig="locsg" pos="noun">Ovddit geasis</errormorphsyn> <errormorphsyn cat="genpl" const="obj" correct="čoggen ollu joŋaid ja sarridiid" errtype="case" orig="nompl" pos="noun"><errormorphsyn cat="genpl" const="obj" correct="čoggen ollu joŋaid" errtype="case" orig="nompl" pos="noun"><errorort correct="čoggen" errtype="mono" pos="verb">čoaggen</errorort> ollu jokŋat</errormorphsyn> ja sarridat</errormorphsyn></p>',

    '<p>Bruk ((epoxi)$(noun,cons|epoksy) lim)¢(noun,mix|epoksylim) med god kvalitet.</p>'
        => '<p>Bruk  <errorortreal correct="epoksylim" errtype="mix" pos="noun"><errorort correct="epoksy" errtype="cons" pos="noun">epoxi</errorort> lim</errorortreal> med god kvalitet.</p>',
    );

    foreach ( keys %question_answer ) {
        test_twig_handler( \&add_error_markup, $_, $question_answer{$_},
            "Error markup" );
    }
}

test_add_error_markup;