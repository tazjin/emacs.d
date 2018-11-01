;; Configure additional settings if this is one of my NixOS machines
;; (i.e. if ExWM is required)
;; -*- lexical-binding: t; -*-

(require 's)
(require 'f)
(require 'dash)

(defun pulseaudio-ctl (cmd)
  (shell-command (concat "pulseaudio-ctl " cmd))
  (message "Volume command: %s" cmd))

(defun volume-mute () (interactive) (pulseaudio-ctl "mute"))
(defun volume-up () (interactive) (pulseaudio-ctl "up"))
(defun volume-down () (interactive) (pulseaudio-ctl "down"))

(defun brightness-up ()
  (interactive)
  (shell-command "exec light -A 10")
  (message "Brightness increased"))

(defun brightness-down ()
  (interactive)
  (shell-command "exec light -U 10")
  (message "Brightness decreased"))

(defun lock-screen ()
  (interactive)
  (shell-command "screen-lock"))

(defun generate-randr-config ()
  (-flatten `(,(-map (lambda (n) (list n "DP2")) (number-sequence 1 7))
              (0 "eDP1")
              ,(-map (lambda (n) (list n "eDP1")) (number-sequence 8 9)))))

(use-package exwm
  :hook ((exwm-update-class . (lambda ()
                                ;; Make class name the buffer name
                                (exwm-workspace-rename-buffer exwm-class-name))))
  :init
  (progn
    (require 'exwm-config)

    (fringe-mode 3)

    (setq exwm-workspace-number 10)

    ;; 's-r': Reset
    (exwm-input-set-key (kbd "s-r") #'exwm-reset)
    ;; 's-w': Switch workspace
    (exwm-input-set-key (kbd "s-w") #'exwm-workspace-switch)
    ;; 's-N': Switch to certain workspace
    (dotimes (i 10)
      (exwm-input-set-key (kbd (format "s-%d" i))
                          `(lambda ()
                             (interactive)
                             (exwm-workspace-switch-create ,i))))

    ;; Launch applications with completion (dmenu style!)
    (exwm-input-set-key (kbd "s-d") #'ivy-run-external-command)
    (exwm-input-set-key (kbd "s-p") #'ivy-password-store)
    (exwm-input-set-key (kbd "C-s-p") '(lambda ()
                                         (interactive)
                                         (ivy-password-store "~/.aprila-secrets")))

    ;; Add Alacritty selector to a key
    (exwm-input-set-key (kbd "C-x t") #'counsel-switch-to-alacritty)

    ;; Toggle between line-mode / char-mode
    (exwm-input-set-key (kbd "C-c C-t C-t") #'exwm-input-toggle-keyboard)

    ;; Volume keys
    (exwm-input-set-key (kbd "<XF86AudioMute>") #'volume-mute)
    (exwm-input-set-key (kbd "<XF86AudioRaiseVolume>") #'volume-up)
    (exwm-input-set-key (kbd "<XF86AudioLowerVolume>") #'volume-down)

    ;; Brightness keys
    (exwm-input-set-key (kbd "<XF86MonBrightnessDown>") #'brightness-down)
    (exwm-input-set-key (kbd "<XF86MonBrightnessUp>") #'brightness-up)
    (exwm-input-set-key (kbd "<XF86Display>") #'lock-screen)

    ;; Line-editing shortcuts
    (exwm-input-set-simulation-keys
     '(([?\C-d] . delete)
       ([?\C-w] . ?\C-c)))

    ;; Enable EXWM
    (exwm-enable)

    ;; Show time in the mode line
    (display-time-mode)

    ;; Configure xrandr when running on laptop
    (when (equal (shell-command-to-string "hostname") "adho\n")
      (require 'exwm-randr)
      (setq exwm-randr-workspace-output-plist (generate-randr-config))
      (exwm-randr-enable))

    ;; Let buffers move seamlessly between workspaces
    (setq exwm-workspace-show-all-buffers t)
    (setq exwm-layout-show-all-buffers t)))

(provide 'nixos)
