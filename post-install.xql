xquery version "1.0";

import module namespace xdb="http://exist-db.org/xquery/xmldb";

(: The following external variables are set by the repo:deploy function :)

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;

(: fix permission and ownership :)

(: COLLECTIONS :)
let $op := xmldb:create-collection($target, "/collections")
let $op := sm:chgrp(xs:anyURI(concat($target, "/collections")), 'jmmc')
let $op := sm:chmod(xs:anyURI(concat($target, "/collections")), 'rwxrwxr-x')

(: TMP :)
let $op := xmldb:create-collection($target, "/tmp")
let $op := sm:chmod( xs:anyURI(concat($target,"/tmp")), "rwxrwxrwx")

(: LOG FILES :)
let $op := xmldb:create-collection($target, "log")
let $op := xmldb:store( concat($target,"/log"), "downloads.xml", <downloads/>)
let $op := xmldb:store( concat($target,"/log"), "searches.xml", <searches/>)
let $op := xmldb:store( concat($target,"/log"), "submits.xml", <submits/>)
let $op := sm:chmod( xs:anyURI(concat($target,"/log/downloads.xml")), "rw-rw-rw-")
let $op := sm:chmod( xs:anyURI(concat($target,"/log/searches.xml")), "rw-rw-rw-")
let $op := sm:chmod( xs:anyURI(concat($target,"/log/submits.xml")), "rw-rw-rw-")

(: OIFITS STAGING :)
let $op := xmldb:create-collection($target, "oifits")
let $op := xmldb:create-collection(concat($target,"/oifits"), "staging")
(: TODO fix owner to reduce anomymous access :)
(: you can also do it by hand from the existd collection manager :)
let $op := sm:chmod( xs:anyURI(concat($target,"/oifits/staging")), "rwxrwxrwx")

return true()
