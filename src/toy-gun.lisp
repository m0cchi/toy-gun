(in-package :cl-user)
(defpackage toy-gun
  (:use :cl)
  (:use :usocket)
  (:use :bordeaux-threads)
  (:export :start
           :dispose
           :*log*
           :*cartridge*
           :make-server))

(in-package :toy-gun)

(defparameter *log* t)
(defparameter *cartridge* '())

(defun make-server (&key (port 8080) (address "localhost"))
  (usocket:socket-listen address port :reuseaddress t :element-type '(unsigned-byte 8)))

(defun accept (server)
  (usocket:socket-accept server))

(defun dispose (server)
  (format *log* "dispose server~%")
  (usocket:socket-close server))

(defun handler (client)
  (handler-case
   (with-open-stream (stream (usocket:socket-stream client))
                     (funcall *cartridge* stream))
   (error (c) (format t "~%dump error: ~a~%" c))))

(defun start (server)
  (unless *cartridge*
    (error "(setq toy-gun:*cartrige* #'your-ink)"))
  (format *log* "start server~%")
  (let ((sock '()))
    (unwind-protect
        (loop (setq sock (accept server))
              (bordeaux-threads:make-thread
               (lambda ()
                 (handler sock)))))
    (dispose server)))
