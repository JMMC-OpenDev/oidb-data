xquery version "3.0";

module namespace kw="http://apps.jmmc.fr/exist/apps/oidb/restxq/keyword";

declare namespace rest="http://exquery.org/ns/restxq";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

(:~
 : Return as JSON a list of keywords matching a query or all.
 : 
 : @param $q the pattern to search in keywords
 : @return a JavaScript array of keywords
 :)
declare
    %rest:GET
    %rest:path("/oidb/keyword")
    %rest:query-param("q", "{$q}")
    %output:method("text")
    %output:media-type("application/json")
function kw:list($q as xs:string*) as xs:string {
    let $keywords := if (exists($q)) then
            collection("/db/oidb/keywords")//keyword[contains(upper-case(.), upper-case($q))]/text()
        else
            collection("/db/oidb/keywords")//keyword/text()
    (: reformat sequence as JavaScript array :)
    return concat(
        "[",
        string-join(for $kw in $keywords return '"' || $kw || '"', ','),
        "]")
};
