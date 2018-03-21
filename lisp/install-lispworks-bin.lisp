(roswell:include "util-install-quicklisp")
(defpackage :roswell.install.lispworks-bin
  (:use :cl :roswell.install :roswell.util :roswell.locations))
(in-package :roswell.install.lispworks-bin)

(defparameter *lispworks-tar-uri*
  (uiop:getenv "LISPWORKS_URI"))
(defparameter *lispworks-tar-key*
  (uiop:getenv "LISPWORKS_TAR_KEY"))
(defparameter *lispworks-serial*
  (uiop:getenv "LISPWORKS_SERIAL"))
(defparameter *lispworks-license*
  (uiop:getenv "LISPWORKS_LICENSE"))

(defun lispworks-bin-get-version ()
  `("current"))

(defun ros/archives/ ()
  (merge-pathnames "archives/ "(homedir)))

(defun ros/impls/ ()
  (merge-pathnames
   (format nil "impls/")
   (homedir)))

(defun uri-pathname-name-and-type (uri)
  (let ((pos (position #\/ uri :from-end t)))
    (let ((possible-name-and-type (subseq uri (1+ pos))))
      (if possible-name-and-type
          possible-name-and-type
          uri))))

(defun lispworks-bin-impl ()
  (merge-pathnames
   (format nil "~A/~A/lispworks-bin/" (uname-m) (uname))
   (ros/impls/)))

(defun lispworks-bin-download (argv)
  (set-opt "as"
           (getf argv :version))
  (set-opt "download.uri"
           *lispworks-tar-uri*)
  (set-opt "download.archive"
           (merge-pathnames (uri-pathname-name-and-type *lispworks-tar-uri*)
                            (ros/archives/)))
  `((,(opt "download.archive") ,(opt "download.uri"))))

(defun lispworks-bin-install (argv)
  (let* ((root (lispworks-bin-impl))
         (dest (merge-pathnames (format nil "~a/" (opt "as")) root)))
    (format t "~%Extracting archive:~A~%" (opt "download.archive"))
        ;;; TODO decrypt if necessary
    (expand
     (opt "download.archive")
     (ensure-directories-exist (lispworks-bin-impl)))
    (and (probe-file dest)
         (uiop/filesystem:delete-directory-tree
          dest :validate t))
    (ql-impl-util:rename-directory
     (merge-pathnames "lispworks/" root)
     dest))
  (cons t argv))

(defun lispworks-bin-license (argv)
  ;;; archive should have already been expanded (HOWTO check?)
  ;;; TODO license binary
  (uiop:run-program
   (format nil "~a --lwlicenseserial ~a --lwlicensekey ~a"
           "lwpro"
           *lispworks-serial*
           *lispworks-license*))
  (cons t argv))

(defun lispworks-bin-patch (argv)
  ;;;   code needs to be private
  (error "Unimplemented patch after licensing."))

(defun lispworks-bin-help (argv)
  "Help")

(defun lispworks-bin (type)
  (case type
    (:help '(lispworks-bin-help))
    (:list 'lispworks-bin-version)
    (:install  `(,(decide-version 'lispworks-bin-get-version) ;; unused??
                  ,(decide-download 'lispworks-bin-download)
                  lispworks-bin-install
                  lispworks-bin-license
                  setup))))


  

