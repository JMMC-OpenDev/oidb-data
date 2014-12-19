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
let $op := for $name in ("downloads","searches","submits", "visits") 
    let $sop := xmldb:store( concat($target,"/log"), concat($name, ".xml"), element {$name} {})
    let $cop := sm:chmod( xs:anyURI(concat($target,"/log/", $name, ".xml")), "rw-rw-rw-")
    return ()

(: OIFITS STAGING :)
let $op := xmldb:create-collection($target, "oifits")
let $op := xmldb:create-collection(concat($target,"/oifits"), "staging")
let $op := sm:chgrp(xs:anyURI(concat($target, "/oifits/staging")), "jmmc")
let $op := sm:chmod(xs:anyURI(concat($target, "/oifits/staging")), "rwxrwxr-x")

return true()
