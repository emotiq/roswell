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
  `("7.1.0.0"))

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

(defun lispworks-tar-root-directory ()
  "LispWorks/")

(defun lispworks-bin-install (argv)
  (let* ((root (lispworks-bin-impl))
         (dest (merge-pathnames (format nil "~a/" (opt "as")) root)))
    (let ((archive
	   (if (string-equal (pathname-type (opt "download.archive"))
			     "crypt")
	       (lispworks-decrypt-archive (opt "download.archive"))
	       (opt "download.archive"))))
    (format t "~%Extracting archive:~A~%" archive)
    (expand
     archive
     (ensure-directories-exist (lispworks-bin-impl)))
    (and (probe-file dest)
         (uiop/filesystem:delete-directory-tree
          dest :validate t))
    (ql-impl-util:rename-directory
     (merge-pathnames (lispworks-tar-root-directory) root)
     dest))
    (cons t argv)))

(defun lispworks-decrypt-archive (pathname &key (suffix ".crypt"))
  (let* ((s (namestring pathname))
	 (out (subseq s 0 (search suffix s))))
    (format t "~&Decrypting~&~t~a~&as~&~t~a~&" pathname out)
    (let ((result 
	   (uiop:run-program 
	    (format nil "openssl enc -d -aes-256-cbc -in ~a -out ~a -pass env:~a" 
		    pathname out "LISPWORKS_TAR_KEY")
	    :output :string :error :string)))
      (format t "~&got stdout/stderr: ~a~&" result)

       (values 
       (pathname out)
       result))))

;; TODO remove lispworks-bin version from binary filesystem name, but
;; for now, there's only one, so this will be good enough.
(defun lispworks-bin-name ()
;; also needs to change in <file:../src/cmd-run-lw.c> 
  "lwpro")

(defun lispworks-bin-license (argv)
  (let ((date 
	 (uiop:run-program "echo -n `/bin/date +%d%m%y`" 
			  :output :string))
	(id 
	 (uiop:run-program "echo -n `id -u`"
			  :output :string))
	(root (merge-pathnames
	       (make-pathname :directory `(:relative ,(opt "as")))
	       (lispworks-bin-impl))))

    (let ((lwlicfile (format nil "/tmp/.~alispworks~a" date id)))
      (uiop:run-program `("touch" ,lwlicfile))
      (uiop:run-program `("chmod" "600" ,lwlicfile)))
    
    #+(or) ;;; not necessary?
    (uiop:run-program `("touch" 
			,(format nil "~a/~a"
				 root
				 "lib/7-1-0-0/config/lwlicense")))
    (uiop:run-program
     (format nil "~a --lwlicenseserial ~a --lwlicensekey ~a"
	   ;;; FIXME: use more of the Roswell machinery to introspect
	   ;;; the pathname location of the binary
	   (merge-pathnames 
	    (make-pathname :name (pathname-name (lispworks-bin-name))
			   :type (pathname-type (lispworks-bin-name)))
	    root)
	   *lispworks-serial*
           *lispworks-license*))
    (cons t argv)))

(defun lispworks-bin-patch (argv)
  ;;; Does the patch code needs to be private by licensing requirements?
  ;;; currently we push all necessary
  ;;;  patches into the tarball, but in the future it 
  (error "Unimplemented patch after licensing."))

(defun lispworks-bin-help (argv)
  "This help intentionally left blank.")

(defun lispworks-bin (type)
  (case type
    (:help '(lispworks-bin-help))
    (:list 'lispworks-bin-version)
    (:install  `(,(decide-version 'lispworks-bin-get-version) ;; unused??
                  ,(decide-download 'lispworks-bin-download)
                  lispworks-bin-install
                  lispworks-bin-license
                  setup))))


  

