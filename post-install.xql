xquery version "3.0";

import module namespace xdb="http://exist-db.org/xquery/xmldb";

(: The following external variables are set by the repo:deploy function :)

(: file path pointing to the exist installation directory :)
declare variable $home external;
(: path to the directory containing the unpacked .xar package :)
declare variable $dir external;
(: the target collection into which the app is deployed :)
declare variable $target external;

(:~
 : Apply set of permissions to a resource.
 : 
 : If any of the permission items is false or unspecified, the respective 
 : permission of the resource is not modified.
 : 
 : @param $path the path to the resource to modify (relative to package root)
 : @param $perms a sequence of user, group and mods to set
 : @return empty
 :)
declare function local:set-permissions($path as xs:string, $perms as item()*) as empty() {
    let $uri := xs:anyURI($path)
    return (
        let $user := $perms[1]
        return if ($user)  then sm:chown($uri, $user) else (),
        let $group := $perms[2]
        return if ($group) then sm:chgrp($uri, $group) else (),
        let $mod := $perms[3]
        return if ($mod)   then sm:chmod($uri, $mod) else ()
    )
};

(: create directory tree and set permissions :)
(
    (: COLLECTIONS :)
    let $collections := xmldb:create-collection($target, 'collections')
    return local:set-permissions($collections, ( false(), 'jmmc', 'rwxrwxr-x' )),

    (: TMP :)
    let $tmp := xmldb:create-collection($target, 'tmp')
    return local:set-permissions($tmp, ( false(), false(), 'rwxrwxrwx' )),

    (: LOG FILES :)
    let $dir := xmldb:create-collection($target, "log")
    let $logs := ( 'downloads', 'searches', 'submits' )
    return
        for $l in $logs
        (: create the empty XML document :)
        let $log := xmldb:store($dir, $l || '.xml', element { $l } {})
        return local:set-permissions($log, ( false(), false(), 'rw-rw-rw-' )),

    (: OIFITS STAGING :)
    let $staging := xmldb:create-collection($target, 'oifits/staging')
    return local:set-permissions($staging, ( false(), 'jmmc', 'rwxrwxr-x' )),

    (: COMMENTS :)
    let $comments := xmldb:store(xmldb:create-collection($target, 'comments'), 'comments.xml', <comments/>)
    return local:set-permissions($comments, ( false(), 'jmmc', 'rw-rw-r--' ))
)
