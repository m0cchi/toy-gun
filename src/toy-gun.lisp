(in-package :cl-user)
(defpackage toy-gun
  (:use :cl)
  (:use :usocket)
  (:use :bordeaux-threads)
  (:export start
           *log*
           *cartridge*))

(in-package :toy-gun)

(defparameter *log* t)
(defparameter *cartridge* '())

(defun make-server-socket (port address)
  (usocket:socket-listen address port :reuseaddress t))

(defun accept (server)
  (usocket:socket-accept server))

(defun dispose (server)
  (format *log* "dispose server~%")
  (usocket:socket-close server))

(defun select (client)
  (with-open-stream (stream (usocket:socket-stream client))
                    (loop for input = (read-char stream nil nil)
                          while input do
                          (funcall *cartridge* stream input))))

(defun start (&key (port 8080) (address "localhost"))
  (unless *cartridge*
    (error "(setq toy-gun:*cartrige* #'your-ink)"))
  (format *log* "start server~%")
  (let ((server-sock (make-server-socket port address)) (sock '()))
    (unwind-protect
        (loop (setq sock (accept server-sock))
              (bordeaux-threads:make-thread
               (lambda ()
                 (select sock))))
      (dispose server-sock))))
