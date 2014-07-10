xquery version "3.0";

(:~
 : The module provides endpoints to data in the ASPRO configuration files for
 : facilities, instruments and modes.
 :)
module namespace instrument="http://apps.jmmc.fr/exist/apps/oidb/restxq/instrument";

declare namespace rest="http://exquery.org/ns/restxq";

declare namespace a="http://www.jmmc.fr/aspro-oi/0.1";

(:~
 : The path to the ASPRO XML configuration in the database.
 :)
declare variable $instrument:asproconf-uri := '/db/apps/oidb-data/instruments';

(:~
 : Return a list of all instruments known with their hosting facilities.
 : 
 : @return an XML documents with <instrument/> elements.
 :)
declare
    %rest:GET
    %rest:path("/oidb/instrument")
function instrument:list() as element(instruments) {
    <instruments> {
        let $facilities := collection($instrument:asproconf-uri)/a:interferometerSetting/description
        
        let $instruments := $facilities/focalInstrument
        for $i in $instruments
        return <instrument facility="{$i/../name}" name="{$i/name/text()}"/>
    } </instruments>
};

(:~
 : Return a list of modes of a given instrument.
 : 
 : @param $name the name of the instrument in ASPRO conf
 : @return an XML documents with <mode/> elements.
 :)
declare
    %rest:GET
    %rest:path("/oidb/instrument/{$name}/mode")
function instrument:modes($name as xs:string) as element(modes) {
    <modes> {
        let $instrument := collection($instrument:asproconf-uri)/a:interferometerSetting/description/focalInstrument[./name=$name]
        let $modes := $instrument/mode
        (: for same instrument at 2 facilities, return only one set of modes :)
        for $m in distinct-values($modes/name/text())
        return element { 'mode' } { $m }
    } </modes>
};
