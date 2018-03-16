(roswell:include "util-install-quicklisp")
(defpackage :roswell.install.lispworks-bin
  (:use :cl :roswell.install :roswell.util :roswell.locations))
(in-package :roswell.install.lispworks-bin)

(defun lispworks-bin-version (argv)
  (mapcar #'first '(("1970-01-01" "0" "0"))))

(defun lispworks-bin-install (argv)
  (let ((uri (opt "uri"))
        (impl-path (merge-pathnames
                    (format nil "impls/~A/~A/~A/" (uname-m) (uname) (getf argv :target)) (homedir))))
    (ensure-directories-exist impl-path)
    ;;; download the URI

    ;;; decrypt the URI

    ;;; stage the URI to local filesystem

    ;;; license the binary
    (cons t argv)))


(defun lispworks-bin (type)
  (case type
    (:help '(lispworks-bin-help))
    (:list 'lispworks-bin-version)
    (:install  `(,(decide-version 'lispworks-bin-version)
                  lispworks-bin-install))))


  


    #|
    (:install `(,(decide-version 'abcl-bin-get-version)
                abcl-bin-argv-parse
                ,(decide-download 'abcl-bin-download)
                abcl-bin-expand
                abcl-bin-script
                setup))
|#

