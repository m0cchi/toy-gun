#|
Author: mocchit
|#

(in-package :cl-user)
(defpackage toy-gun-asd
  (:use :cl :asdf))
(in-package :toy-gun-asd)

(defsystem toy-gun
  :version "0.0.1"
  :author "mocchi"
  :license "BSD License"
  :depends-on (:usocket
               :bordeaux-threads)
  :components ((:module "src"
                :components
                ((:file "toy-gun"))))
  :description "abstract server")
