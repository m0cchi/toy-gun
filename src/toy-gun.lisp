(in-package :cl-user)
(defpackage toy-gun
  (:use :cl
        :iolib)
  (:export :start
           :dispose
           :*log*
           :*cartridge*
           :*debug-log*
           :make-server))

(in-package :toy-gun)

(defparameter *log* t)
(defparameter *debug-log* nil)
(defparameter *cartridge* '())

(defun make-server (&key (port 8080) (address "localhost"))
  (let ((socket (iolib.sockets:make-socket :address-family :ipv4
                                           :type :stream
                                           :connect :passive
                                           :local-host address
                                           :local-port port
                                           :reuse-address t)))
    (iolib.sockets::listen-on socket)
    socket))

(defun dispose (server)
  (format *debug-log* "dispose server~%")
  (handler-case (close server)
                (error (c) c)))

(defun handler (client)
  (handler-case
   (funcall *cartridge* client)
   (error (c) (format *debug-log* "~%dump error: ~a~%" c))))

(defun fd-handler (server event-base)
  (let* ((socket (iolib.sockets:accept-connection server))
         (fd (iolib.streams:fd-of socket)))
    (iolib.multiplex:set-io-handler event-base fd
                                    :read  (lambda (_fd _ev _e)
                                             (declare (ignore _fd _ev _e))
                                             (handler socket)))))

(defun start (server)
  (unless *cartridge*
    (error "(setq toy-gun:*cartrige* #'your-ink)~%"))
  (format *log* "start server~%")
  (let ((ev (make-instance 'iolib.multiplex:event-base)))
    (iolib.multiplex::set-io-handler ev
                                     (iolib.streams:fd-of server)
                                     :read (lambda (fd event exception)
                                             (declare (ignore fd event exception))
                                             (fd-handler server ev)))
    (unwind-protect
        (iolib.multiplex:event-dispatch ev)
      (dispose server))))
