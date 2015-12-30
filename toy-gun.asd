#|
URL: https://github.com/mocchit/toy-gun
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
  :depends-on (:iolib)
  :components ((:module "src"
                        :components
                ((:file "toy-gun"))))
  :description "abstract server")
