(require 'dash)
(require 'f)
(require 'helm)
(require 's)

(defvar memomd-dir-path "~/Dropbox/memo/"  ;; "~/.memomd/"
  "Directory path for storing all of memo data")



(defun memomd-dir (dirpath)
  "Set dir path globally."
  (setq memomd-dir-path dirpath))

(defun memomd-open-file (filename)
  "Open filename"
  (find-file (f-join memomd-dir-path filename)))

(defun memomd-dir-md ()
  "List of files in the dir."
  (-filter
   (lambda (x) (s-ends-with? ".md" x))
   (directory-files memomd-dir-path)))

(defun memomd-title (filename)
  "Title of the file"
  (car (s-lines
        (f-read-text
         (f-join memomd-dir-path filename)))))

(defun memomd-as-candidate (filename)
  "Candidate style of filename like '2017-1.. -- This is title'"
  (concat filename " -- " (memomd-title filename)))

(defun memomd-candidate-to-filename (candidate)
  "Convert candidate name into filename"
  (car (s-split-up-to " -- " candidate 1)))

(defun memomd-candidates ()
  (reverse (-map 'memomd-as-candidate (memomd-dir-md))))

(defun memomd-open-candidate (candidate)
  "Open candidate as file"
  (memomd-open-file (memomd-candidate-to-filename candidate)))


;; Interactive commands

(defun memomd-open ()
  "Open memo file"
  (interactive)
  (helm :sources
        (helm-make-source "memomd" 'helm-source-sync
          :candidates 'memomd-candidates
          ;; :migemo t
          :action 'memomd-open-candidate)
        :prompt ""
        :input ""
        :buffer "*helm-memomd-open*"))

(defun memomd-new ()
  "Open new note under the memo dir."
  (interactive)
  (setq filename (format-time-string "%Y-%m-%dT%H:%M:%S.md" (current-time)))
  (memomd-open-file filename))

(provide 'memomd)
