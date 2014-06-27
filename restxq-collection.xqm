xquery version "3.0";

module namespace coll="http://apps.jmmc.fr/exist/apps/oidb/restxq/collection";

import module namespace xmldb="http://exist-db.org/xquery/xmldb";
import module namespace responde="http://exist-db.org/xquery/response";

declare namespace rest="http://exquery.org/ns/restxq";

declare
    %rest:GET
    %rest:path("/oidb/collection")
function coll:list() as element(collections) {
    <collections>
    {
        for $c in collection("/db/oidb/collections")/collection
        return <collection id="{$c/@id}" created="{$c/@created}"/>
    }
    </collections>
};

declare
    %rest:GET
    %rest:path("/oidb/collection/{$id}")
function coll:retrieve-collection($id as xs:string) as element(collection)? {
    collection("/db/oidb/collections")/collection[@id eq xmldb:decode($id)]
};

declare
    %rest:PUT("{$collection-doc}")
    %rest:path("/oidb/collection/{$id}")
function coll:store-collection($id as xs:string, $collection-doc as document-node()) as xs:boolean {
    let $existing-collection := coll:retrieve-collection($id)
    let $filename :=
        if (not(empty($existing-collection))) then
            document-uri(root($existing-collection))  
        else
            ()
    return not(empty(
        xmldb:store(
            "/db/oidb/collections",
            $filename,
            (: TODO set updated instead of created if already exists :)
            <collection id="{xmldb:decode($id)}" created="{current-dateTime()}">
                { $collection-doc/collection/* }
            </collection>
        )
    ))
};