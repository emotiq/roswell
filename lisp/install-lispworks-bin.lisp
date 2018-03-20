(roswell:include "util-install-quicklisp")
(defpackage :roswell.install.lispworks-bin
  (:use :cl :roswell.install :roswell.util :roswell.locations))
(in-package :roswell.install.lispworks-bin)

(defparameter *lispworks-tar-uri*
  (uiop:getenv "LISPWORKS_URI"))
(defparameter *lispworks-tar-key*
  (uiop:getenv "LISPWORKS_TAR_KEY"))
(defparameter *lispworks-licenses*
  (uiop:getenv "LISPWORKS_LICENSE"))
(defparameter *lispworks-serial*
  (uiop:getenv "LISPWORKS_SERIAL"))

(defun lispworks-bin-get-version ()
  '("1970-01-01" "0" "0"))

(defun lispworks-bin-impl ()
  (merge-pathnames
   (format nil "impls/~A/~A/lispworks-bin/" (uname-m) (uname)) (homedir)))

(defun lispworks-bin-download (argv)
  `(,(merge-pathnames (format nil "archives/~a" "foo.tar.gz") (homedir))
     "https://slack.net/foo"))

(defun lispworks-bin-install (argv)
  (let ((uri (opt "uri"))
        (impl-path (lispworks-bin-impl)))
    (ensure-directories-exist impl-path)
    ;;; download the URI

    ;;; decrypt the URI

    ;;; stage the URI to local filesystem

    ;;; license the binary
    (cons t argv)))

(defun lispworks-bin-help (argv)
  "Help")


(defun lispworks-bin (type)
  (case type
    (:help '(lispworks-bin-help))
    (:list 'lispworks-bin-version)
    (:install  `(,(decide-version 'lispworks-bin-get-version)
                  lispworks-bin-install))))


  


    #|
    (:install `(,(decide-version 'abcl-bin-get-version)
                abcl-bin-argv-parse
                ,(decide-download 'abcl-bin-download)
                abcl-bin-expand
                abcl-bin-script
                setup))
|#

