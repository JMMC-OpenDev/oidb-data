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
        for $c in collection("/db/apps/oidb-data/collections")/collection
        return <collection id="{$c/@id}" created="{$c/@created}"/>
    }
    </collections>
};

declare %private function coll:find($id as xs:string) as element(collection)? {
    collection("/db/apps/oidb-data/collections")/collection[@id eq $id]
};

declare
    %rest:GET
    %rest:path("/oidb/collection/{$id}")
function coll:retrieve-collection($id as xs:string) {
    let $collection := coll:find(xmldb:decode($id))
    return
        if ($collection) then $collection
        else <rest:response><http:response status="404"/></rest:response>
};

declare
    %rest:PUT("{$collection-doc}")
    %rest:path("/oidb/collection/{$id}")
function coll:store-collection($id as xs:string, $collection-doc as document-node()) {
    let $id := xmldb:decode($id)
    let $collection := coll:find($id)
    let $filename :=
        if ($collection) then
            (: update collection :)
            document-uri(root($collection))
        else
            (: new collection :)
            ()
    let $collection :=
        <collection id="{$id}"> {
            if ($collection) then ( $collection/@created, attribute { "updated" } { current-dateTime() } )
            else attribute { "created" } { current-dateTime() },
            $collection-doc/collection/*
        } </collection>
    let $path := xmldb:store("/db/apps/oidb-data/collections", $filename, $collection)
    return <rest:response>
        <http:response> { attribute { "status" } {
            if ($filename and $path) then 204 (: No Content :)
            else if ($path)          then 201 (: Created :)
            else                          400 (: Bad Request :)
        } } </http:response>
    </rest:response>
};
