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
  (usocket:socket-listen address port :reuseaddress t :element-type '(unsigned-byte 8)))

(defun accept (server)
  (usocket:socket-accept server))

(defun dispose (server)
  (format *log* "dispose server~%")
  (usocket:socket-close server))

(defun handler (client)
  (with-open-stream (stream (usocket:socket-stream client))
                    (handler-case (funcall *cartridge* stream)
                                  (error (c) (format t "~%dump error: ~a~%" c)))))

(defun start (&key (port 8080) (address "localhost"))
  (unless *cartridge*
    (error "(setq toy-gun:*cartrige* #'your-ink)"))
  (format *log* "start server~%")
  (let ((server-sock (make-server-socket port address)) (sock '()))
    (unwind-protect
        (loop (setq sock (accept server-sock))
              (bordeaux-threads:make-thread
               (lambda ()
                 (handler sock)))))
    (dispose server-sock)))
