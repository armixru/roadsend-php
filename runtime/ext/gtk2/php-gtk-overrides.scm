;; ***** BEGIN LICENSE BLOCK *****
;; Roadsend PHP Compiler Runtime Libraries
;; Copyright (C) 2007 Roadsend, Inc.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU Lesser General Public License
;; as published by the Free Software Foundation; either version 2.1
;; of the License, or (at your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU Lesser General Public License for more details.
;; 
;; You should have received a copy of the GNU Lesser General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
;; ***** END LICENSE BLOCK *****
(module php-gtk-overrides
   (load (php-macros "../../../php-macros.scm"))
   (load (php-gtk-macros "php-gtk-macros.sch"))
;   (library common)
   (library profiler)
   (import
    (gtk-binding "cigloo/gtk.scm")
    (gtk-signals "cigloo/signals.scm")
    (php-gtk-common-lib "php-gtk-common.scm")
;;     (gtk-enums-lib "gtk-enums.scm")
;;     (gdk-enums-lib "gdk-enums.scm")
    (php-gdk-lib "php-gdk.scm")
    (php-gtk-lib "php-gtk.scm")
    (php-gtk-signals "php-gtk-signals.scm"))
   (export
    (init-php-gtk-overrides)
    (ctree-callback ctree::GtkCTree* node::GtkCTreeNode* callback::procedure))
   (extern
    (export ctree-callback "ctree_callback")))

(define (init-php-gtk-overrides)
   1)

(def-static-method Gtk (true)
   TRUE)

(def-static-method Gtk (false)
   FALSE)

; (defmethod GtkSelectionData (set type format data)
;    (let* ((this::GtkSelectionData* (gtk-object $this))
; 	  (type::GdkAtom (php-gdk-atom-get (maybe-unbox type)))
; 	  (format::int (mkfixnum format))
; 	  (data::string (mkstr data))
; 	  (len::int (string-length data)))
;       (gtk_selection_data_set this type format (pragma::guchar-array-256 "$1" data) len)
;       NULL))






; PHP_FUNCTION(gtk_object_get_data)
; {
; 	char *key;
; 	zval *data;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "s", &key))
; 		return;

; 	data = gtk_object_get_data(PHP_GTK_GET(this_ptr), key);
; 	if (data) {
; 		*return_value = *data;
; 		zval_copy_ctor(return_value);
; 	}
; }

; (defmethod GtkObject (get_data key)
;    (let ((data::gpointer (gtk_object_get_data (gtk-object $this)
; 					      (mkstr key))))
;       (if (foreign-null? data)
; 	  NULL
; 	  (copy-php-data (pragma::obj "$1" data)))))


; PHP_FUNCTION(gtk_object_set_data)
; {
; 	char *key;
; 	zval *data;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "sV", &key, &data))
; 		return;

; 	zval_add_ref(&data);
; 	gtk_object_set_data_full(PHP_GTK_GET(this_ptr), key, data, php_gtk_destroy_notify);
; }

; (defmethod GtkObject (set_data key data)
;    (let ((data::gpointer (pragma::gpointer "$1" (maybe-unbox data))))
;       (pragma "extern obj_t phpgtk_destroy_notify(obj_t)")
;       (reference data)
;       (gtk_object_set_data_full (gtk-object $this)
; 				(mkstr key)
; 				data
; 				(pragma::GtkDestroyNotify
; 				 "(GtkDestroyNotify)phpgtk_destroy_notify"))
;       NULL))

; PHP_FUNCTION(gtk_selection_data_set)
; {
; 	zval *type;
; 	int format, length;
; 	guchar *data;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "Ois#", &type, gdk_atom_ce, &format, &data, &length))
; 		return;

; 	gtk_selection_data_set(PHP_GTK_SELECTION_DATA_GET(this_ptr), PHP_GDK_ATOM_GET(type), format, data, length);
; 	RETURN_NULL();
; }

; override gtk_input_add_full
; void php_gtk_input_marshal(gpointer a, gpointer data, int nargs, GtkArg *args)
; {
; 	zval *callback_data = (zval *)data;
; 	zval *params;
; 	zval *retval = NULL, **callback, **extra = NULL;
; 	zval **callback_filename = NULL, **callback_lineno = NULL;
; 	zval **source_rsrc = NULL;
; 	zval ***input_args;
; 	char *callback_name;
; 	TSRMLS_FETCH();

; 	zend_hash_index_find(Z_ARRVAL_P(callback_data), 0, (void **)&callback);
; 	zend_hash_index_find(Z_ARRVAL_P(callback_data), 1, (void **)&source_rsrc);
; 	zend_hash_index_find(Z_ARRVAL_P(callback_data), 2, (void **)&extra);
; 	zend_hash_index_find(Z_ARRVAL_P(callback_data), 3, (void **)&callback_filename);
; 	zend_hash_index_find(Z_ARRVAL_P(callback_data), 4, (void **)&callback_lineno);

; 	if (!php_gtk_is_callable(*callback, 0, &callback_name)) {
; 		php_error(E_WARNING, "Unable to call input callback '%s' specified in %s on line %d", callback_name, Z_STRVAL_PP(callback_filename), Z_LVAL_PP(callback_lineno));
; 		efree(callback_name);
; 		return;
; 	}

; 	params = php_gtk_args_as_hash(nargs, args);
; 	/*
; 	 * We substitute the first argument with the actual resource zval.
; 	 */
; 	zval_add_ref(source_rsrc);
; 	zend_hash_index_update(Z_ARRVAL_P(params), 0, (void*)source_rsrc, sizeof(zval *), NULL);
; 	if (extra)
; 		php_array_merge(Z_ARRVAL_P(params), Z_ARRVAL_PP(extra), 0 TSRMLS_CC);
; 	input_args = php_gtk_hash_as_array(params);
; 	call_user_function_ex(EG(function_table), NULL, *callback, &retval, zend_hash_num_elements(Z_ARRVAL_P(params)), input_args, 0, NULL TSRMLS_CC);
; 	if (retval)
; 		zval_ptr_dtor(&retval);
; 	efree(input_args);
; 	zval_ptr_dtor(&params);
; }

; PHP_FUNCTION(gtk_input_add_full)
; {
; 	zval *source_rsrc;
; 	int source;
; 	int rsrc_type;
;     GdkInputCondition condition;
; 	zval *callback = NULL;
; 	zval *extra, *data;
; 	char *callback_filename;
; 	uint callback_lineno;

; 	if (ZEND_NUM_ARGS() < 3) {
; 		php_error(E_WARNING, "%s() requires at least 3 arguments, %d given",
; 				  get_active_function_name(TSRMLS_C), ZEND_NUM_ARGS());
; 		return;
; 	}

; 	if (!php_gtk_parse_args(3, "riV", &source_rsrc, &condition, &callback))
; 		return;

; #ifdef PHP_HAVE_STREAMS
; 	{
; 		php_stream *stream;
; 		stream = zend_list_find(Z_LVAL_P(source_rsrc), &rsrc_type);
; 		if (!stream || rsrc_type != php_file_le_stream()) {
; 			php_error(E_WARNING, "%s() expects argument 1 to be a valid stream resource", get_active_function_name(TSRMLS_C));
; 			return;
; 		}
; 		if (php_stream_can_cast(stream, PHP_STREAM_AS_SOCKETD) == SUCCESS) {
; 			php_stream_cast(stream, PHP_STREAM_AS_SOCKETD, (void*)&source, 0);
; 		} else if (php_stream_can_cast(stream, PHP_STREAM_AS_FD) == SUCCESS) {
; 			php_stream_cast(stream, PHP_STREAM_AS_FD, (void*)&source, 0);
; 		} else {
; 			php_error(E_WARNING, "%s() could not use stream of type '%s'",
; 					  get_active_function_name(TSRMLS_C), stream->ops->label);
; 			return;
; 		}
; 	}
; #else
; 	{
; 		void *source_ptr;

; 		source_ptr = zend_list_find(Z_LVAL_P(source_rsrc), &rsrc_type);
; 		if (!source_ptr ||
; 			(rsrc_type != php_file_le_fopen() && rsrc_type != php_file_le_popen() && rsrc_type != php_file_le_socket())) {
; 			php_error(E_WARNING, "%s() expects argument 1 to be a valid filehandle, pipe, or socket resource", get_active_function_name(TSRMLS_C));
; 			return;
; 		}
; 		if (rsrc_type == php_file_le_socket())
; 			source = *((int *)source_ptr);
; 		else
; 			source = fileno((FILE *)source_ptr);
; 	}
; #endif
	
; 	callback_filename = zend_get_executed_filename(TSRMLS_C);
; 	callback_lineno = zend_get_executed_lineno(TSRMLS_C);
; 	extra = php_gtk_func_args_as_hash(ZEND_NUM_ARGS(), 3, ZEND_NUM_ARGS());
; 	data = php_gtk_build_value("(VVNsi)", callback, source_rsrc, extra, callback_filename, callback_lineno);
; 	RETURN_LONG(gtk_input_add_full(source, condition, NULL,
; 								   (GtkCallbackMarshal)php_gtk_input_marshal,
; 								   data, php_gtk_destroy_notify));
; }
; %%
; override gtk_signal_add_emission_hook

; static void php_gtk_emission_hook_marshal(GtkObject *o, guint signal_id, guint nargs, GtkArg *args, gpointer data)
; {
; 	zval *callback_data = (zval *)data;
; 	zval *gtk_args;
; 	zval **callback, **extra = NULL;
; 	zval **callback_filename = NULL, **callback_fileno = NULL;
; 	zval ***hook_args;
; 	zval *wrapper = NULL;
; 	zval *params;
; 	zval *retval = NULL;
; 	char *callback_name;
; 	TSRMLS_FETCH();

; 	/* Callback is always passed as the first element. */
; 	zend_hash_index_find(Z_ARRVAL_P(callback_data), 0, (void**)&callback);

; 	/* Extra parametrers are always passed as the second element. */
; 	zend_hash_index_find(Z_ARRVAL_P(callback_data), 1, (void**)&extra);

; 	/* Third and fourth parameter are always filename and the line number where
; 	 * the callback was specified. */
; 	zend_hash_index_find(Z_ARRVAL_P(callback_data), 2, (void**)&callback_filename);
; 	zend_hash_index_find(Z_ARRVAL_P(callback_data), 3, (void**)&callback_fileno);

; 	if (!php_gtk_is_callable(*callback, 0, &callback_name)) {
; 		php_error(E_WARNING, "Unable to call emission hook '%s' specified in %s on line %d", callback_name, Z_STRVAL_PP(callback_filename), Z_LVAL_PP(callback_fileno));
; 		efree(callback_name);
; 		return;
; 	}

; 	wrapper = php_gtk_new(o);

; 	/* Prepare the parameters to be passed to the user function. */
; 	MAKE_STD_ZVAL(params);
; 	array_init(params);
; 	/* Pass the object which emitted the signal as first parameer. */
; 	add_next_index_zval(params, wrapper);
; 	/* Pass the signal id as second parameter. */
; 	add_next_index_long(params, signal_id);

; 	gtk_args = php_gtk_args_as_hash(nargs, args);
; 	php_array_merge(Z_ARRVAL_P(params), Z_ARRVAL_P(gtk_args), 0 TSRMLS_CC);

; 	zval_ptr_dtor(&gtk_args);

; 	/*
; 	 * If there are extra arguments specified by user, add them to the parameter
; 	 * array.
; 	 */
; 	if (extra)
; 		php_array_merge(Z_ARRVAL_P(params), Z_ARRVAL_PP(extra), 0 TSRMLS_CC);
	
; 	hook_args = php_gtk_hash_as_array(params);

; 	call_user_function_ex(EG(function_table), NULL, *callback, &retval,
; 						  zend_hash_num_elements(Z_ARRVAL_P(params)), hook_args,
; 						  0, NULL TSRMLS_CC);
	
; 	if (retval) {
; 		if (args)
; 			php_gtk_ret_from_value(&args[nargs], retval);
; 		zval_ptr_dtor(&retval);
; 	}

; 	efree(hook_args);
; 	zval_ptr_dtor(&params);
; }

; PHP_FUNCTION(gtk_signal_add_emission_hook)
; {
; 	guint signal_id;
; 	zval  *callback;
; 	char  *callback_filename;
; 	uint  callback_lineno;
; 	zval  *extra;
; 	zval  *data;

; 	if (ZEND_NUM_ARGS() < 2) {
; 		php_error(E_WARNING, "%s() requires at least 2 arguments, %d given",
; 				  get_active_function_name(TSRMLS_C), ZEND_NUM_ARGS());
; 		return;
; 	}

; 	if (!php_gtk_parse_args(2, "iV", &signal_id, &callback))
; 		return;
	
; 	callback_filename = zend_get_executed_filename(TSRMLS_C);
; 	callback_lineno   = zend_get_executed_lineno(TSRMLS_C);
; 	extra = php_gtk_func_args_as_hash(ZEND_NUM_ARGS(), 2, ZEND_NUM_ARGS());
; 	data  = php_gtk_build_value("(VNsi)", callback, extra, callback_filename, callback_lineno);
; 	RETURN_LONG(gtk_signal_add_emission_hook_full(signal_id,
; 												  (GtkEmissionHook)php_gtk_emission_hook_marshal,
; 												  data, php_gtk_destroy_notify));
; }

(defmethod GtkBox (query_child_packing child)
   (let ((this (GTK_BOX (gtk-object $this)))
	 (child (GTK_WIDGET (gtk-object child)))
	 (expand::bool 0)
	 (fill::bool 0)
	 (padding::guint 0)
	 (pack_type::int 0))
      (pragma "gtk_box_query_child_packing($1, $2, &$3, &$4, &$5, (GtkPackType*)&$6)"
	      this child expand fill padding pack_type)
      (list->php-hash (list (convert-to-boolean expand)
			    (convert-to-boolean fill)
			    (convert-to-integer padding)
			    (convert-to-integer pack_type)))))


(defmethod GtkCalendar (get_data)
   (let ((year::int 0)
	 (month::int 0)
	 (day::int 0))
      (gtk_calendar_get_date (GTK_CALENDAR (gtk-object $this))
			     (pragma::guint* "&$1" year)
			     (pragma::guint* "&$1" month)
			     (pragma::guint* "&$1" day))
      (list->php-hash (list year month day))))

(defmethod GtkCList (get_text row column)
   (let ((text::string ""))
      (if (zero? (gtk_clist_get_text (GTK_CLIST (gtk-object $this))
				     (mkfixnum row)
				     (mkfixnum column)
				     (pragma::string* "&$1" text)))
	  (begin
	     (php-warning "cannot get text value.")
	     NULL)
	  text)))

(defmethod GtkCList (get_pixmap row column)
   (let ((pixmap::GdkPixmap* (pragma::GdkPixmap* "NULL"))
	 (mask::GdkBitmap* (pragma::GdkBitmap* "NULL")))
      (if (zero? (gtk_clist_get_pixmap (GTK_CLIST (gtk-object $this))
				       (mkfixnum row)
				       (mkfixnum column)
				       (pragma::GdkPixmap** "&$1" pixmap)
				       (pragma::GdkBitmap** "&$1" mask)))
	  (php-warning "cannot get pixmap value")
	  (list->php-hash
	   (list (gtk-wrapper-new 'gdkpixmap pixmap)
		 (gtk-wrapper-new 'gdkbitmap mask))))))


(defmethod GtkCList (set_row_data row data)
   (reference data)
   (pragma "extern obj_t phpgtk_destroy_notify(obj_t data)")
   (gtk_clist_set_row_data_full (GTK_CLIST (gtk-object $this))
				row
				(pragma::gpointer "$1" data)
				(pragma::GtkDestroyNotify "phpgtk_destroy_notify"))
   NULL)

(defmethod GtkCList (get_row_data row)
   ;;; I don't know why the copy call is necessary, but it's in php-gtk
   (let ((data (pragma::obj "gtk_clist_get_row_data($1, $2)"
			    (GTK_CLIST (gtk-object $this))
			    (mkfixnum row))))
      (if (pragma::bool "$1" data)
	  (copy-php-data data)
	  NULL)))

(defmethod GtkCList (find_row_from_data data)
   (convert-to-number
    (gtk_clist_find_row_from_data (GTK_CLIST (gtk-object $this))
				  (pragma::gpointer "$1" data))))

(defmethod GtkCList (get_pixtext row column)
   (let ((pixmap::GdkPixmap* (pragma::GdkPixmap* "NULL"))
	 (mask::GdkBitmap* (pragma::GdkBitmap* "NULL"))
	 (text::string "")
	 (spacing::int 0))
      (if (zero? (gtk_clist_get_pixtext (GTK_CLIST (gtk-object $this))
					(mkfixnum row)
					(mkfixnum column)
					(pragma::string* "&$1" text)
					(pragma::guint8* "&$1" spacing)
					(pragma::GdkPixmap** "&$1" pixmap)
					(pragma::GdkBitmap** "&$1" mask)))
	  (php-warning "cannot get pixtext value")
	  (list->php-hash
	   (list (convert-to-number spacing)
		 text
		 (gtk-wrapper-new 'gdkpixmap pixmap)
		 (gtk-wrapper-new 'gdkbitmap mask))))))


(defmethod GtkCList (get_text row column)
   (let ((this::GtkCList* (GTK_CLIST (gtk-object $this)))
	 (row::int (mkfixnum row))
	 (column::int (mkfixnum column))
	 (text::string ""))
      (if (zero? (pragma::int "gtk_clist_get_text($1, $2, $3, &$4)"
			       this row column text))
	  (php-warning "cannot get text value: gtk_clist_get_text returned 0")
	  text)))

(defmethod GtkCList (get_selection_info x y)
   (let ((row::int 0)
	 (column::int 0))
      (if (zero?
	   (gtk_clist_get_selection_info (GTK_CLIST (gtk-object $this))
					 x
					 y
					 (pragma::gint* "&$1" row)
					 (pragma::gint* "&$1" column)))
	  FALSE
	  (list->php-hash (list (convert-to-number row)
				(convert-to-number column))))))


(defmethod GtkColorSelection (set_color red green blue #!optional (opacity 1.0))
   (let ((red::double (onum->float (convert-to-number red)))
	 (green::double (onum->float (convert-to-number green)))
	 (blue::double (onum->float (convert-to-number blue)))
	 (opacity::double (onum->float (convert-to-number opacity)))
	 (this::GtkColorSelection* (GTK_COLOR_SELECTION (gtk-object $this))))
   (pragma "{ gdouble value[4] = {$2, $3, $4, $5};
 gtk_color_selection_set_color($1, value); }"
	   this red green blue opacity)
   NULL))



; (defmethod gtkcolorselection (get_color)
;    (let ((red::double (pragma::double "0.0"))
; 	 (green::double (pragma::double "0.0"))
; 	 (blue::double (pragma::double "0.0"))
; 	 (opacity::double (pragma::double "0.0"))
; 	 (this::GtkColorSelection* (GTK_COLOR_SELECTION (gtk-object $this))))
;       (pragma "{ gdouble value[4];
;  gtk_color_selection_get_color($1, value);
;  $2 = value[0]; $3 = value[1]; $4 = value[2]; $5 = value[3];}"
; 	      this red green blue opacity)
;       (if (pragma::bool "$1->use_opacity" this)
; 	  (list->php-hash (map convert-to-number (list red green blue opacity)))
; 	  (list->php-hash (map convert-to-number (list red green blue))))))


(defmethod GtkCombo (set_popdown_strings strings)
   (let ((strings (maybe-unbox strings)))
      (if (not (php-hash? strings))
	  (php-warning "strings should be an array")
	  (let ((lst
		 (let loop ((lst::GList* (pragma::GList* "NULL"))
			    (strings (php-hash->list strings)))
		       (if (pair? strings)
			   (let ((s::string (convert-to-utf8 (car strings))))
			      (loop (pragma::GList* "g_list_append($1, $2)" lst s)
				    (cdr strings)))
			   lst))))
	     (let ((glst::GList* lst)
		   (this::GtkCombo* (GTK_COMBO (gtk-object $this))))
		(pragma "gtk_combo_set_popdown_strings(GTK_COMBO($1), $2)" this glst)
		(pragma "g_list_free($1)" glst)
		NULL))))
   NULL)


; (defmethod GtkContainer (children)
;    (list->php-hash
;     (map (lambda (o)
; 	    (gtk-object-wrapper-new #f o))
; 	 (glist->list (gtk_container_children (GTK_CONTAINER (gtk-object $this)))
; 		       'bs-_GtkObject*))))

(define (ctree-callback ctree::GtkCTree* node::GtkCTreeNode* callback::procedure)
   (callback (gtk-object-wrapper-new 'GtkCTree* ctree)
	     (php-gtk-ctree-node-new node)))
      



; %%
; override gtk_ctree_post_recursive
; static void ctree_callback(GtkCTree *ctree, GtkCTreeNode *node, zval *callback_data)
; {
; 	zval *retval = NULL;
; 	zval **callback = NULL, **extra = NULL;
; 	zval **callback_filename = NULL, **callback_lineno = NULL;
; 	zval ***args, *params;
; 	char *callback_name;
; 	TSRMLS_FETCH();

; 	zend_hash_index_find(Z_ARRVAL_P(callback_data), 0, (void **)&callback);
; 	zend_hash_index_find(Z_ARRVAL_P(callback_data), 1, (void **)&extra);
; 	zend_hash_index_find(Z_ARRVAL_P(callback_data), 2, (void **)&callback_filename);
; 	zend_hash_index_find(Z_ARRVAL_P(callback_data), 3, (void **)&callback_lineno);

; 	if (!php_gtk_is_callable(*callback, 0, &callback_name)) {
; 		php_error(E_WARNING, "Unable to call ctree callback '%s' specified in %s on line %d", callback_name, Z_STRVAL_PP(callback_filename), Z_LVAL_PP(callback_lineno));
; 		efree(callback_name);
; 		return;
; 	}

; 	params = php_gtk_build_value("(NN)", php_gtk_new((GtkObject *)ctree),
; 								 php_gtk_ctree_node_new(node));
; 	if (extra)
; 		php_array_merge(Z_ARRVAL_P(params), Z_ARRVAL_PP(extra), 0 TSRMLS_CC);

; 	args = php_gtk_hash_as_array(params);

; 	call_user_function_ex(EG(function_table), NULL, *callback, &retval, zend_hash_num_elements(Z_ARRVAL_P(params)), args, 0, NULL TSRMLS_CC);
; 	if (retval)
; 		zval_ptr_dtor(&retval);
; 	efree(args);
; 	zval_ptr_dtor(&params);
; }


; static void traverse_ctree(INTERNAL_FUNCTION_PARAMETERS, zend_bool use_depth, zend_bool pre_order)
; {
; 	zval *php_node, *callback;
; 	zval *data, *extra;
; 	GtkCTreeNode *node = NULL;
; 	gint depth;
; 	int req_args = 2;
; 	char *callback_filename;
; 	uint callback_lineno;


; 	if (Z_TYPE_P(php_node) != IS_NULL)
; 		node = PHP_GTK_CTREE_NODE_GET(php_node);

; 	callback_filename = zend_get_executed_filename(TSRMLS_C);
; 	callback_lineno = zend_get_executed_lineno(TSRMLS_C);
; 	extra = php_gtk_func_args_as_hash(ZEND_NUM_ARGS(), 2, ZEND_NUM_ARGS());
; 	data = php_gtk_build_value("(VNsi)", callback, extra, callback_filename, callback_lineno);
; 	if (pre_order) {
; 		if (use_depth)
; 			gtk_ctree_pre_recursive_to_depth(GTK_CTREE(PHP_GTK_GET(this_ptr)),
; 											 node, depth,
; 											 (GtkCTreeFunc)ctree_callback, data);
; 		else
; 			gtk_ctree_pre_recursive(GTK_CTREE(PHP_GTK_GET(this_ptr)), node,
; 									(GtkCTreeFunc)ctree_callback, data);
; 	} else {
; 		if (use_depth)
; 			gtk_ctree_post_recursive_to_depth(GTK_CTREE(PHP_GTK_GET(this_ptr)),
; 											  node, depth,
; 											  (GtkCTreeFunc)ctree_callback, data);
; 		else
; 			gtk_ctree_post_recursive(GTK_CTREE(PHP_GTK_GET(this_ptr)), node,
; 									 (GtkCTreeFunc)ctree_callback, data);
; 	}
; }

(defmethod GtkCtree (post_recursive node callback #!rest extra)
   (let ((node (gtk-object/safe 'GtkCTreeNode node return))
	 (this (GTK_CTREE (gtk-object/safe 'GtkCTree $this return)))
	 (callback (maybe-unbox callback))
	 (extra (map maybe-unbox extra)))
      (gtk_ctree_post_recursive this node
				(pragma::GtkCTreeFunc "ctree_callback")
				(pragma::void* "$1" (phpgtk-callback-closure callback extra #t #f)))
      NULL))



   ; 	NOT_STATIC_METHOD();

; 	if (use_depth)
; 		req_args = 3;

; 	if (ZEND_NUM_ARGS() < req_args) {
; 		php_error(E_WARNING, "%s() requires at least %d arguments, %d given",
; 				  get_active_function_name(TSRMLS_C), req_args, ZEND_NUM_ARGS());
; 		return;
; 	}

; 	if (use_depth) {
; 		if (!php_gtk_parse_args(3, "NiV", &php_node, gtk_ctree_node_ce, &depth, &callback))
; 			return;
; 	} else {
; 		if (!php_gtk_parse_args(2, "NV", &php_node, gtk_ctree_node_ce, &callback))
; 			return;
; 	}
;)
; PHP_FUNCTION(gtk_ctree_post_recursive)
; {
; 	traverse_ctree(INTERNAL_FUNCTION_PARAM_PASSTHRU, 0, 0);
; }
; %%
; override gtk_ctree_post_recursive_to_depth
; PHP_FUNCTION(gtk_ctree_post_recursive_to_depth)
; {
; 	traverse_ctree(INTERNAL_FUNCTION_PARAM_PASSTHRU, 1, 0);
; }
; %%
; override gtk_ctree_pre_recursive
; PHP_FUNCTION(gtk_ctree_pre_recursive)
; {
; 	traverse_ctree(INTERNAL_FUNCTION_PARAM_PASSTHRU, 0, 1);
; }
; %%
; override gtk_ctree_pre_recursive_to_depth
; PHP_FUNCTION(gtk_ctree_pre_recursive_to_depth)
; {
; 	traverse_ctree(INTERNAL_FUNCTION_PARAM_PASSTHRU, 1, 1);
; }
; %%
; override gtk_ctree_get_node_info
; PHP_FUNCTION(gtk_ctree_get_node_info)
; {
; 	zval *node;
; 	zval *php_pixmap_closed, *php_mask_closed;
; 	zval *php_pixmap_opened, *php_mask_opened;
; 	gchar *text;
; 	guint8 spacing;
; 	GdkPixmap *pixmap_closed, *pixmap_opened;
; 	GdkBitmap *mask_closed, *mask_opened;
; 	gboolean is_leaf, expanded;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "O", &node, gtk_ctree_node_ce))
; 		return;

; 	if (!gtk_ctree_get_node_info(GTK_CTREE(PHP_GTK_GET(this_ptr)),
; 								 PHP_GTK_CTREE_NODE_GET(node), &text, &spacing,
; 								 &pixmap_closed, &mask_closed, &pixmap_opened,
; 								 &mask_opened, &is_leaf, &expanded)) {
; 		php_error(E_WARNING, "%s() cannot get node info", get_active_function_name(TSRMLS_C));
; 		return;
; 	}

; 	php_pixmap_closed = php_gdk_pixmap_new(pixmap_closed);
; 	php_pixmap_opened = php_gdk_pixmap_new(pixmap_opened);
; 	php_mask_closed = php_gdk_bitmap_new(mask_closed);
; 	php_mask_opened = php_gdk_bitmap_new(mask_opened);

; 	*return_value = *php_gtk_build_value("(siNNNNbb)", text, (int)spacing,
; 										 php_pixmap_closed, php_mask_closed,
; 										 php_pixmap_opened, php_mask_opened,
; 										 (int)is_leaf, (int)expanded);
; }
; %%

(defmethod GtkCTree (node_set_row_data node data)
   (let ((this::GtkCTree* (GTK_CTREE (gtk-object $this)))
	 (node::GtkCTreeNode* (gtk-object/safe 'GtkCTreeNode node return)))
      ;; this function chucks the data in a hashtable on the bigloo side
      ;; so it won't get GC'd and then come back from the dead
      (gtk-ctree-node-set-row-data this node data)))

(defmethod GtkCTree (node_get_row_data node)
   (let ((this::GtkCTree* (GTK_CTREE (gtk-object $this)))
	 (node::GtkCTreeNode* (gtk-object/safe 'GtkCTreeNode node return)))
      (gtk-ctree-node-get-row-data this node)))

; override gtk_ctree_node_get_row_data
; PHP_FUNCTION(gtk_ctree_node_get_row_data)
; {
; 	zval *node, *data;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "O", &node, gtk_ctree_node_ce))
; 		return;

; 	data = gtk_ctree_node_get_row_data(GTK_CTREE(PHP_GTK_GET(this_ptr)),
; 									   PHP_GTK_CTREE_NODE_GET(node));
; 	if (data) {
; 		*return_value = *data;
; 		zval_copy_ctor(return_value);
; 	} else {
; 		RETURN_NULL();
; 	}
; }
; %%

(defmethod GtkCTree (node_get_text node column)
    (let (($this::GtkCTree*
            (if (php-null? (maybe-unbox $this))
              (pragma::GtkCTree* "NULL")
              (GTK_CTREE
                (gtk-object/safe 'GtkCTree $this return))))
          (node::GtkCTreeNode*
            (if (php-null? (maybe-unbox node))
              (pragma::GtkCTreeNode* "NULL")
              (gtk-object/safe 'GtkCTreeNode node return)))
          (column::int (mkfixnum column))
	  (text::string* (pragma::string* "NULL")))
       (when (zero? (gtk_ctree_node_get_text $this node column (pragma::string* "&$1" text)))
	  (php-warning "cannot get text value")
	  (return NULL))
       (if (pragma::bool "($1 != NULL)" text)
	   (convert-to-codepage text)
	   NULL)))

; override gtk_ctree_node_get_text
; PHP_FUNCTION(gtk_ctree_node_get_text)
; {
; 	zval *node;
; 	gint column;
; 	gchar *text = NULL;
; #ifdef PHP_WIN32
; 	gchar *cp_text = NULL;
; #endif

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "Oi", &node, gtk_ctree_node_ce, &column))
; 		return;

; 	if (!gtk_ctree_node_get_text(GTK_CTREE(PHP_GTK_GET(this_ptr)),
; 								 PHP_GTK_CTREE_NODE_GET(node), column, &text)) {
; 		php_error(E_WARNING, "%s() cannot get text value", get_active_function_name(TSRMLS_C));
; 		return;
; 	}

; #ifdef PHP_WIN32
; 	if (text) {
; 		cp_text = g_convert(text, strlen(text), GTK_G(codepage), "UTF-8", NULL, NULL, NULL);
; 		RETURN_STRING(cp_text, 1);
; 		g_free(cp_text);
; 	}
; 	else {
; 		RETURN_NULL();
; 	}
; #else
; 	RETURN_STRING(text, 1);
; #endif
; }
; %%
; override gtk_ctree_node_get_pixmap
; PHP_FUNCTION(gtk_ctree_node_get_pixmap)
; {
; 	zval *node, *php_pixmap, *php_mask;
; 	int column;
; 	GdkPixmap *pixmap = NULL;
; 	GdkBitmap *mask = NULL;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "Oi", &node, gtk_ctree_node_ce, &column))
; 		return;

; 	if (!gtk_ctree_node_get_pixmap(GTK_CTREE(PHP_GTK_GET(this_ptr)),
; 								   PHP_GTK_CTREE_NODE_GET(node), column,
; 								   &pixmap, &mask)) {
; 		php_error(E_WARNING, "%s() cannot get pixmap value", get_active_function_name(TSRMLS_C));
; 		return;
; 	}
	
; 	php_pixmap = php_gdk_pixmap_new(pixmap);
; 	php_mask = php_gdk_bitmap_new(pixmap);

; 	*return_value = *php_gtk_build_value("(NN)", php_pixmap, php_mask);
; }
; %%
; override gtk_ctree_node_get_pixtext
; PHP_FUNCTION(gtk_ctree_node_get_pixtext)
; {
; 	zval *node, *php_pixmap = NULL, *php_mask = NULL;
; 	int column;
; 	gchar *text = NULL;
; 	guint8 spacing;
; 	GdkPixmap *pixmap = NULL;
; 	GdkBitmap *mask = NULL;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "Oi", &node, gtk_ctree_node_ce, &column))
; 		return;

; 	if (!gtk_ctree_node_get_pixtext(GTK_CTREE(PHP_GTK_GET(this_ptr)),
; 									PHP_GTK_CTREE_NODE_GET(node), column, &text,
; 									&spacing, &pixmap, &mask)) {
; 		php_error(E_WARNING, "%s() cannot get pixtext value", get_active_function_name(TSRMLS_C));
; 		return;
; 	}

; 	php_pixmap = php_gdk_pixmap_new(pixmap);
; 	php_mask = php_gdk_bitmap_new(mask);

; 	*return_value = *php_gtk_build_value("(siNN)", text, (int)spacing,
; 										 php_pixmap, php_mask);
; }

; %%
; override gtk_ctree_find_by_row_data
; PHP_FUNCTION(gtk_ctree_find_by_row_data)
; {
; 	zval *php_node, *data, *php_ret;
; 	GtkCTreeNode *ret;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "OV", &php_node, gtk_ctree_node_ce,
; 							&data))
; 		return;

; 	ret = gtk_ctree_find_by_row_data(GTK_CTREE(PHP_GTK_GET(this_ptr)),
; 									 PHP_GTK_CTREE_NODE_GET(php_node), data);
; 	php_ret = php_gtk_ctree_node_new(ret);
; 	SEPARATE_ZVAL(&php_ret);
; 	*return_value = *php_ret;
; }

; %%
; override gtk_ctree_find_all_by_row_data
; PHP_FUNCTION(gtk_ctree_find_all_by_row_data)
; {
; 	zval *php_node, *data;
; 	zval *item;
; 	GList *ret, *tmp;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "OV", &php_node, gtk_ctree_node_ce,
; 							&data))
; 		return;

; 	ret = gtk_ctree_find_all_by_row_data(GTK_CTREE(PHP_GTK_GET(this_ptr)),
; 										 PHP_GTK_CTREE_NODE_GET(php_node), data);
; 	array_init(return_value);
; 	for (tmp = ret; tmp != NULL; tmp = tmp->next) {
; 		item = php_gtk_ctree_node_new((GtkCTreeNode *)tmp->data);
; 		add_next_index_zval(return_value, item);
; 	}
; 	g_list_free(ret);
; }

; %%
; getprop GtkCTree selection
; 	GList *tmp;
; 	GList *selection = GTK_CLIST(PHP_GTK_GET(object))->selection;
; 	zend_overloaded_element *property;
; 	zend_llist_element *next = (*element)->next;
; 	int prop_index;

; 	if (next) {
; 		int i = 0;
; 		property = (zend_overloaded_element *)next->data;
; 		if (Z_TYPE_P(property) == OE_IS_ARRAY && Z_TYPE(property->element) == IS_LONG) {
; 			*element = next;
; 			prop_index = Z_LVAL(property->element);
; 			for (tmp = selection, i = 0; tmp; tmp = tmp->next, i++) {
; 				if (i == prop_index) {
; 					*return_value = *php_gtk_ctree_node_new(GTK_CTREE_NODE(tmp->data));
; 					return;
; 				}
; 			}
; 		}
; 	} else {
; 		array_init(return_value);
; 		for (tmp = selection; tmp; tmp = tmp->next)
; 			add_next_index_zval(return_value, php_gtk_ctree_node_new(GTK_CTREE_NODE(tmp->data)));
; 	}
; %%
; getprop GtkCTree clist
; 	*return_value = *php_gtk_new((GtkObject *)GTK_CLIST(PHP_GTK_GET(object)));
; %%
; getprop GtkCTree row_list
; 	GList *tmp;
; 	GList *row_list = GTK_CLIST(PHP_GTK_GET(object))->row_list;
; 	zend_overloaded_element *property;
; 	zend_llist_element *next = (*element)->next;
; 	int prop_index;

; 	if (next) {
; 		int i = 0;
; 		property = (zend_overloaded_element *)next->data;
; 		if (Z_TYPE_P(property) == OE_IS_ARRAY && Z_TYPE(property->element) == IS_LONG) {
; 			*element = next;
; 			prop_index = Z_LVAL(property->element);
; 			for (tmp = row_list, i = 0; tmp; tmp = tmp->next, i++) {
; 				if (i == prop_index) {
; 					*return_value = *php_gtk_ctree_node_new(GTK_CTREE_NODE(tmp));
; 					return;
; 				}
; 			}
; 		}
; 	} else {
; 		array_init(return_value);
; 		for (tmp = row_list; tmp; tmp = tmp->next) {
; 			add_next_index_zval(return_value, php_gtk_ctree_node_new(GTK_CTREE_NODE(tmp)));
; 		}
; 	}
; %% }}}

; %% {{{ GtkCurve

; %%
; override gtk_curve_get_vector
; PHP_FUNCTION(gtk_curve_get_vector)
; {
; 	int veclen = -1, i;
; 	gfloat *vector = NULL;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "|i", &veclen))
; 		return;

; 	if (veclen < 0)
; 		veclen = GTK_CURVE(PHP_GTK_GET(this_ptr))->num_points;
; 	vector = emalloc(sizeof(gfloat) * veclen);
; 	gtk_curve_get_vector(GTK_CURVE(PHP_GTK_GET(this_ptr)), veclen, vector);
; 	array_init(return_value);
; 	for (i = 0; i < veclen; i++)
; 		add_index_double(return_value, i, vector[i]);
; 	efree(vector);
; }
; %%
; override gtk_curve_set_vector
; PHP_FUNCTION(gtk_curve_set_vector)
; {
; 	int veclen, i;
; 	gfloat *vector = NULL;
; 	zval *php_vector, **temp_vector;
; 	HashTable *target_hash;
	
; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "a", &php_vector))
; 		return;

; 	target_hash = HASH_OF(php_vector);
; 	veclen = zend_hash_num_elements(target_hash);
; 	vector = emalloc(sizeof(gfloat) * veclen);
; 	zend_hash_internal_pointer_reset(target_hash);
; 	i = 0;
; 	while (zend_hash_get_current_data(target_hash, (void **)&temp_vector) == SUCCESS) {
; 		vector[i++] = (gfloat)Z_DVAL_PP(temp_vector);
; 		zend_hash_move_forward(target_hash);
; 	}
	
; 	gtk_curve_set_vector(GTK_CURVE(PHP_GTK_GET(this_ptr)), veclen, vector);
; 	RETURN_TRUE;
; }
; %% }}}

(defmethod GtkEditable (insert_text text pos)
   (let* ((text::string (mkstr text))
	  (len::int (string-length text))
	  (pos::int (mkfixnum pos)))
      (gtk_editable_insert_text (GTK_EDITABLE (gtk-object $this))
				text
				len
				(pragma::gint* "&$1" pos))
      (convert-to-number pos)))

; %% {{{ GtkEditable
; %%
; override gtk_editable_insert_text
; PHP_FUNCTION(gtk_editable_insert_text)
; {
; 	char *text;
; 	int len, pos;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "s#i", &text, &len, &pos))
; 		return;

; 	gtk_editable_insert_text(GTK_EDITABLE(PHP_GTK_GET(this_ptr)), text, len, &pos);
; 	RETURN_LONG(pos);
; }
; %% }}}

; %% {{{ GtkFixed
; %%
; getprop GtkFixed children
; 	GList *tmp;
; 	GList *children = GTK_FIXED(PHP_GTK_GET(object))->children;
; 	zend_overloaded_element *property;
; 	zend_llist_element *next = (*element)->next;
; 	int prop_index;

; 	if (next) {
; 		int i = 0;
; 		property = (zend_overloaded_element *)next->data;
; 		if (Z_TYPE_P(property) == OE_IS_ARRAY && Z_TYPE(property->element) == IS_LONG) {
; 			*element = next;
; 			prop_index = Z_LVAL(property->element);
; 			for (tmp = children, i = 0; tmp; tmp = tmp->next, i++) {
; 				if (i == prop_index) {
; 					*return_value = *php_gtk_fixed_child_new((GtkFixedChild *)tmp->data);
; 					return;
; 				}
; 			}
; 		}
; 	} else {
; 		array_init(return_value);
; 		for (tmp = children; tmp; tmp = tmp->next) {
; 			add_next_index_zval(return_value, php_gtk_fixed_child_new((GtkFixedChild *)tmp->data));
; 		}
; 	}
; %% }}}

; %% {{{ GtkItemFactory
; %%
; override gtk_item_factory_create_items
; static void item_factory_callback(zval *callback_data, guint action, GtkWidget *widget)
; {
; 	zval *retval = NULL;
; 	zval **callback, **extra;
; 	zval **callback_filename, **callback_lineno;
; 	zval *params;
; 	zval ***args;
; 	char *callback_name;
; 	TSRMLS_FETCH();

; 	zend_hash_index_find(Z_ARRVAL_P(callback_data), 0, (void **)&callback);
; 	zend_hash_index_find(Z_ARRVAL_P(callback_data), 1, (void **)&callback_filename);
; 	zend_hash_index_find(Z_ARRVAL_P(callback_data), 2, (void **)&callback_lineno);
; 	if (!php_gtk_is_callable(*callback, 0, &callback_name)) {
; 		php_error(E_WARNING, "unable to call item factory callback '%s' specified in %s on line %d", callback_name, Z_STRVAL_PP(callback_filename), Z_LVAL_PP(callback_lineno));
; 		efree(callback_name);
; 		return;
; 	}

; 	params = php_gtk_build_value("(iN)", action, php_gtk_new((GtkObject *)widget));
; 	if (zend_hash_num_elements(Z_ARRVAL_P(callback_data)) > 3) {
; 		zend_hash_index_find(Z_ARRVAL_P(callback_data), 3, (void **)&extra);
; 		php_array_merge(Z_ARRVAL_P(params), Z_ARRVAL_PP(extra), 0 TSRMLS_CC);
; 	}

; 	args = php_gtk_hash_as_array(params);

; 	call_user_function_ex(EG(function_table), NULL, *callback, &retval, zend_hash_num_elements(Z_ARRVAL_P(params)), args, 0, NULL TSRMLS_CC);
; 	if (retval)
; 		zval_ptr_dtor(&retval);
; 	efree(args);
; 	zval_ptr_dtor(&params);
; }

; PHP_FUNCTION(gtk_item_factory_create_items)
; {
; 	zval *list, **item, *callback_data,
; 		 *callback, *extra = NULL;
; 	GtkItemFactoryEntry entry;
; 	GtkItemFactory *factory;
; 	int i = 0;
; 	char *callback_filename;
; 	uint callback_lineno;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "a", &list))
; 		return;
	
; 	factory = GTK_ITEM_FACTORY(PHP_GTK_GET(this_ptr));
; 	zend_hash_internal_pointer_reset(Z_ARRVAL_P(list));
; 	while (zend_hash_get_current_data(Z_ARRVAL_P(list), (void**)&item) == SUCCESS) {
; 		if (Z_TYPE_PP(item) != IS_ARRAY ||
; 			!php_gtk_parse_args_hash_quiet(*item, "ssVis|a", &entry.path,
; 									 &entry.accelerator, &callback,
; 									 &entry.callback_action, &entry.item_type, &extra)) {
; 			php_error(E_WARNING, "%s() was unable to parse item #%d in the input array",
; 					  get_active_function_name(TSRMLS_C), i+1);
; 			return;
; 		}

; 		if (Z_TYPE_P(callback) == IS_NULL)
; 			entry.callback = NULL;
; 		else {
; 			callback_filename = zend_get_executed_filename(TSRMLS_C);
; 			callback_lineno = zend_get_executed_lineno(TSRMLS_C);
; 			if (extra)
; 				callback_data = php_gtk_build_value("(VsiV)", callback, callback_filename, callback_lineno, extra);
; 			else
; 				callback_data = php_gtk_build_value("(Vsi)", callback, callback_filename, callback_lineno);
; 			entry.callback = (GtkItemFactoryCallback)item_factory_callback;
; 		}

; 		gtk_item_factory_create_item(factory, &entry, callback_data, 1);

; 		i++;
; 		zend_hash_move_forward(Z_ARRVAL_P(list));
; 	}

; 	RETURN_TRUE;
; }
; %% }}}

(defmethod GtkLabel (get)
   (let ((this (GTK_LABEL (gtk-object $this)))
	 (text::string ""))
      (gtk_label_get this (pragma::gchar** "&$1" text))
      text))

; %% {{{ GtkLabel
; %%
; override gtk_label_get
; PHP_FUNCTION(gtk_label_get)
; {
; 	gchar *text;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), ""))
; 		return;

; 	gtk_label_get(GTK_LABEL(PHP_GTK_GET(this_ptr)), &text);
; 	RETURN_STRING(text, 1);
; }
; %% }}}

; %% {{{ GtkList

; %%
; override gtk_list_append_items
; PHP_FUNCTION(gtk_list_append_items)
; {
; 	zval *php_items, **item;
; 	GList *items = NULL;
; 	int i = 0;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "a", &php_items))
; 		return;

; 	for (zend_hash_internal_pointer_reset(Z_ARRVAL_P(php_items));
; 		 zend_hash_get_current_data(Z_ARRVAL_P(php_items), (void **)&item) == SUCCESS;
; 		 zend_hash_move_forward(Z_ARRVAL_P(php_items)), i++) {
; 		if (!php_gtk_check_class(*item, gtk_listitem_ce)) {
; 			php_error(E_WARNING, "%s() needs list item #%d to be a GtkListItem", get_active_function_name(TSRMLS_C), i);
; 			g_list_free(items);
; 			return;
; 		}

; 		items = g_list_append(items, PHP_GTK_GET(*item));
; 	}

; 	gtk_list_append_items(GTK_LIST(PHP_GTK_GET(this_ptr)), items);
; }
; %%
(defmethod GtkList (append_items items)
   (let ((items (maybe-unbox items)))
      (if (not (php-hash? items))
	  (php-warning "items should be an array")
	  (let ((lst
		 (let loop ((lst::GList* (pragma::GList* "NULL"))
			    (items (php-hash->list items))
                            (i 0))
		       (if (pair? items)
                           (if (php-object-is-a (car items) 'GtkListItem)
                               (loop (pragma::GList* "g_list_append($1, $2)" lst
                                                     (GTK_LIST_ITEM (gtk-object (car items))))
                                     (cdr items)
                                     (+ i 1))
                               (begin
                                  (php-warning "list item " i " must be a GtkListItem")
                                  (pragma "g_list_free($1)" lst)
                                  (return NULL)))
			   lst))))
             (let ((glst:Glist* lst)
                   (this::GtkList* (GTK_LIST (gtk-object/safe 'GtkList $this return))))
                (gtk_list_append_items this lst)
                ;; XXX really don't need to free the glist?
                NULL))))
   NULL)
; override gtk_list_prepend_items
; PHP_FUNCTION(gtk_list_prepend_items)
; {
; 	zval *php_items, **item;
; 	GList *items = NULL;
; 	int i = 0;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "a", &php_items))
; 		return;

; 	for (zend_hash_internal_pointer_reset(Z_ARRVAL_P(php_items));
; 		 zend_hash_get_current_data(Z_ARRVAL_P(php_items), (void **)&item) == SUCCESS;
; 		 zend_hash_move_forward(Z_ARRVAL_P(php_items)), i++) {
; 		if (!php_gtk_check_class(*item, gtk_listitem_ce)) {
; 			php_error(E_WARNING, "%s() needs list item #%d to be a GtkListItem", get_active_function_name(TSRMLS_C), i);
; 			g_list_free(items);
; 			return;
; 		}

; 		items = g_list_append(items, PHP_GTK_GET(*item));
; 	}

; 	gtk_list_prepend_items(GTK_LIST(PHP_GTK_GET(this_ptr)), items);
; }
; %%
; override gtk_list_insert_items
; PHP_FUNCTION(gtk_list_insert_items)
; {
; 	zval *php_items, **item;
; 	GList *items = NULL;
; 	int position, i = 0;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "ai", &php_items, &position))
; 		return;

; 	for (zend_hash_internal_pointer_reset(Z_ARRVAL_P(php_items));
; 		 zend_hash_get_current_data(Z_ARRVAL_P(php_items), (void **)&item) == SUCCESS;
; 		 zend_hash_move_forward(Z_ARRVAL_P(php_items)), i++) {
; 		if (!php_gtk_check_class(*item, gtk_listitem_ce)) {
; 			php_error(E_WARNING, "%s() needs list item #%d to be a GtkListItem", get_active_function_name(TSRMLS_C), i);
; 			g_list_free(items);
; 			return;
; 		}

; 		items = g_list_append(items, PHP_GTK_GET(*item));
; 	}

; 	gtk_list_insert_items(GTK_LIST(PHP_GTK_GET(this_ptr)), items, position);
; }
; %%
; override gtk_list_remove_items
; PHP_FUNCTION(gtk_list_remove_items)
; {
; 	zval *php_items, **item;
; 	GList *items = NULL;
; 	int i = 0;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "a", &php_items))
; 		return;

; 	for (zend_hash_internal_pointer_reset(Z_ARRVAL_P(php_items));
; 		 zend_hash_get_current_data(Z_ARRVAL_P(php_items), (void **)&item) == SUCCESS;
; 		 zend_hash_move_forward(Z_ARRVAL_P(php_items)), i++) {
; 		if (!php_gtk_check_class(*item, gtk_listitem_ce)) {
; 			php_error(E_WARNING, "%s() needs list item #%d to be a GtkListItem", get_active_function_name(TSRMLS_C), i);
; 			g_list_free(items);
; 			return;
; 		}

; 		items = g_list_append(items, PHP_GTK_GET(*item));
; 	}

; 	gtk_list_remove_items(GTK_LIST(PHP_GTK_GET(this_ptr)), items);
; 	g_list_free(items);
; }
; %%
; %%
; override gtk_list_item_new
; PHP_FUNCTION(gtk_list_item_new)
; {
; 	GtkObject *wrapped_obj;
; 	gchar *text = NULL;
; #ifdef PHP_WIN32
; 	gchar *utf8_text = NULL;
; #endif

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "|s", &text)) {
; 		php_gtk_invalidate(this_ptr);
; 		return;
; 	}

; 	if (text) {
; #ifdef PHP_WIN32
; 		utf8_text = g_convert(text, strlen(text), "UTF-8", GTK_G(codepage), NULL, NULL, NULL);
; 		wrapped_obj = (GtkObject *)gtk_list_item_new_with_label(utf8_text);
; 		if (utf8_text) g_free(utf8_text);
; #else
; 		wrapped_obj = (GtkObject *)gtk_list_item_new_with_label(text);
; #endif
; 	}
; 	else
; 		wrapped_obj = (GtkObject *)gtk_list_item_new();

; 	if (!wrapped_obj) {
; 		php_error(E_WARNING, "%s(): could not create GtkListItem object",
; 				  get_active_function_name(TSRMLS_C));
; 		php_gtk_invalidate(this_ptr);
; 		return;
; 	}

; 	php_gtk_object_init(wrapped_obj, this_ptr);
; }
; %%
; getprop GtkList selection
; 	GList *tmp;
; 	GList *selection = GTK_LIST(PHP_GTK_GET(object))->selection;
; 	zend_overloaded_element *property;
; 	zend_llist_element *next = (*element)->next;
; 	int prop_index;

; 	if (next) {
; 		int i = 0;
; 		property = (zend_overloaded_element *)next->data;
; 		if (Z_TYPE_P(property) == OE_IS_ARRAY && Z_TYPE(property->element) == IS_LONG) {
; 			*element = next;
; 			prop_index = Z_LVAL(property->element);
; 			for (tmp = selection, i = 0; tmp; tmp = tmp->next, i++) {
; 				if (i == prop_index) {
; 					*return_value = *php_gtk_new((GtkObject *)tmp->data);
; 					return;
; 				}
; 			}
; 		}
; 	} else {
; 		array_init(return_value);
; 		for (tmp = selection; tmp; tmp = tmp->next)
; 			add_next_index_zval(return_value, php_gtk_new((GtkObject *)tmp->data));
; 	}

; %% }}}

; %% {{{ GtkMenu

; %%
; override gtk_menu_attach_to_widget
; static void gtk_menu_detacher(GtkWidget *widget, GtkMenu *menu)
; {
; 	GtkMenu *remove_menu;
; 	g_return_if_fail(widget != NULL);
; 	g_return_if_fail(GTK_IS_MENU(widget));
	
; 	remove_menu = GTK_MENU(widget);
; //	g_return_if_fail(remove_menu->menu == (GtkWidget*) menu);
	
; //	remove_menu->menu = NULL;
; }

; PHP_FUNCTION(gtk_menu_attach_to_widget)
; {
; 	zval *php_widget = NULL;

; 	NOT_STATIC_METHOD();
	
; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "O", &php_widget, gtk_widget_ce))
; 		return;

; 	gtk_menu_attach_to_widget(GTK_MENU(PHP_GTK_GET(this_ptr)), GTK_WIDGET(PHP_GTK_GET(php_widget)), gtk_menu_detacher);
; }
; %%
; override gtk_menu_popup
; static void php_gtk_menu_position(GtkMenu *menu, int *x, int *y, zval *callback_data)
; {
; 	zval **callback;
; 	zval **callback_filename, **callback_lineno;
; 	zval *retval, *params;
; 	zval ***args;
; 	char *callback_name;
; 	TSRMLS_FETCH();

; 	zend_hash_index_find(Z_ARRVAL_P(callback_data), 0, (void **)&callback);
; 	zend_hash_index_find(Z_ARRVAL_P(callback_data), 1, (void **)&callback_filename);
; 	zend_hash_index_find(Z_ARRVAL_P(callback_data), 2, (void **)&callback_lineno);
; 	if (!php_gtk_is_callable(*callback, 0, &callback_name)) {
; 		php_error(E_WARNING, "unable to call menu position callback '%s' specified in %s on line %d", callback_name, Z_STRVAL_PP(callback_filename), Z_LVAL_PP(callback_lineno));
; 		efree(callback_name);
; 		return;
; 	}

; 	params = php_gtk_build_value("(Nii)", php_gtk_new(GTK_OBJECT(menu)), *x, *y);
; 	args = php_gtk_hash_as_array(params);

; 	call_user_function_ex(EG(function_table), NULL, *callback, &retval, zend_hash_num_elements(Z_ARRVAL_P(params)), args, 0, NULL TSRMLS_CC);

; 	if (retval) {
; 		if (Z_TYPE_P(retval) == IS_ARRAY &&
; 			!php_gtk_parse_args_hash_quiet(retval, "ii", x, y)) {
; 			php_error(E_WARNING, "unable to parse result of menu position callback");
; 		}
; 		zval_ptr_dtor(&retval);
; 	}

; 	efree(args);
; 	zval_ptr_dtor(&params);
; }

; PHP_FUNCTION(gtk_menu_popup)
; {
; 	zval *php_pms, *php_pmi;
; 	GtkWidget *pms = NULL, *pmi = NULL;
; 	zval *callback, *data;
; 	int button, time;
; 	char *callback_filename;
; 	uint callback_lineno;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "NNVii", &php_pms, gtk_widget_ce,
; 							&php_pmi, gtk_widget_ce, &callback, &button, &time))
; 		return;

; 	if (Z_TYPE_P(php_pms) != IS_NULL)
; 		pms = GTK_WIDGET(PHP_GTK_GET(php_pms));
; 	if (Z_TYPE_P(php_pmi) != IS_NULL)
; 		pmi = GTK_WIDGET(PHP_GTK_GET(php_pmi));

; 	if (Z_TYPE_P(callback) != IS_NULL) {
; 		callback_filename = zend_get_executed_filename(TSRMLS_C);
; 		callback_lineno = zend_get_executed_lineno(TSRMLS_C);
; 		data = php_gtk_build_value("(Vsi)", callback, callback_filename, callback_lineno);
; 		gtk_menu_popup(GTK_MENU(PHP_GTK_GET(this_ptr)), pms, pmi,
; 					   (GtkMenuPositionFunc)php_gtk_menu_position, data,
; 					   button, time);
; 	} else
; 		gtk_menu_popup(GTK_MENU(PHP_GTK_GET(this_ptr)), pms, pmi, NULL, NULL,
; 					   button, time);
; }

; %% }}}

; %% {{{1 GtkMenuItem

; %%

; %%
; override gtk_menu_item_new
; PHP_FUNCTION(gtk_menu_item_new)
; {
; 	GtkObject *wrapped_obj;
; 	char *label = NULL;
; #ifdef PHP_WIN32
; 	gchar *utf8_label = NULL;
; #endif
	
; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "|s", &label)) {
; 		php_gtk_invalidate(this_ptr);
; 		return;
; 	}

; 	if (label) {
; #ifdef PHP_WIN32
; 		utf8_label = g_convert(label, strlen(label), "UTF-8", GTK_G(codepage), NULL, NULL, NULL);
; 		wrapped_obj = (GtkObject *)gtk_menu_item_new_with_label(utf8_label);
; 		if (utf8_label) g_free(utf8_label);
; #else
; 		wrapped_obj = (GtkObject *)gtk_menu_item_new_with_label(label);		
; #endif
; 	}
; 	else
; 	    wrapped_obj = (GtkObject *)gtk_menu_item_new();

; 	if (!wrapped_obj) {
; 		php_error(E_WARNING, "%s(): could not create GtkMenuItem object",
; 				  get_active_function_name(TSRMLS_C));
; 		php_gtk_invalidate(this_ptr);
; 		return;
; 	}

; 	php_gtk_object_init(wrapped_obj, this_ptr);
; }

; %% }}}

; %% {{{ GtkNotebook
; %%
; override gtk_notebook_query_tab_label_packing
; PHP_FUNCTION(gtk_notebook_query_tab_label_packing)
; {
; 	zval *child;
; 	gboolean expand, fill;
; 	GtkPackType pack_type;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "O", &child, gtk_widget_ce))
; 		return;

; 	gtk_notebook_query_tab_label_packing(GTK_NOTEBOOK(PHP_GTK_GET(this_ptr)),
; 										 GTK_WIDGET(PHP_GTK_GET(child)),
; 										 &expand, &fill, &pack_type);

; 	array_init(return_value);
; 	add_next_index_bool(return_value, expand);
; 	add_next_index_bool(return_value, fill);
; 	add_next_index_long(return_value, pack_type);
; }
; %% }}}

; %% {{{ GtkObject

; %%
; override gtk_signal_connect
; static void gtk_signal_connect_impl(INTERNAL_FUNCTION_PARAMETERS, int pass_object, int after)
; {
; 	char *name = NULL;
; 	zval *callback = NULL;
; 	zval *extra;
; 	zval *data;
; 	char *callback_filename;
; 	uint callback_lineno;

; 	NOT_STATIC_METHOD();

; 	if (ZEND_NUM_ARGS() < 2) {
; 		php_error(E_WARNING, "%s() requires at least 2 arguments, %d given",
; 				  get_active_function_name(TSRMLS_C), ZEND_NUM_ARGS());
; 		return;
; 	}

; 	if (!php_gtk_parse_args(2, "sV", &name, &callback))
; 		return;

; 	callback_filename = zend_get_executed_filename(TSRMLS_C);
; 	callback_lineno = zend_get_executed_lineno(TSRMLS_C);
; 	extra = php_gtk_func_args_as_hash(ZEND_NUM_ARGS(), 2, ZEND_NUM_ARGS());
; 	data = php_gtk_build_value("(VNisi)", callback, extra, pass_object, callback_filename, callback_lineno);
; 	RETURN_LONG(gtk_signal_connect_full(PHP_GTK_GET(this_ptr), name, NULL,
; 										(GtkCallbackMarshal)php_gtk_callback_marshal,
; 										data, php_gtk_destroy_notify, FALSE, after));
; }

; PHP_FUNCTION(gtk_signal_connect)
; {
; 	gtk_signal_connect_impl(INTERNAL_FUNCTION_PARAM_PASSTHRU, 1, 0);
; }
; %%
; override gtk_signal_connect_object
; PHP_FUNCTION(gtk_signal_connect_object)
; {
; 	gtk_signal_connect_impl(INTERNAL_FUNCTION_PARAM_PASSTHRU, 0, 0);
; }
; %%
; override gtk_signal_connect_after
; PHP_FUNCTION(gtk_signal_connect_after)
; {
; 	gtk_signal_connect_impl(INTERNAL_FUNCTION_PARAM_PASSTHRU, 1, 1);
; }
; %%
; override gtk_signal_connect_object_after
; PHP_FUNCTION(gtk_signal_connect_object_after)
; {
; 	gtk_signal_connect_impl(INTERNAL_FUNCTION_PARAM_PASSTHRU, 0, 1);
; }
; %%
; override gtk_signal_emit
; PHP_FUNCTION(gtk_signal_emit)
; {
; 	char *name;
; 	guint signal_id, nparams, i;
; 	GtkSignalQuery *query;
; 	GtkArg *params;
; 	zval *php_params, *ret;
; 	gchar buf[sizeof(GtkArg)]; /* holds the return value */

; 	NOT_STATIC_METHOD();

; 	if (ZEND_NUM_ARGS() < 1) {
; 		php_error(E_WARNING, "%s() requires at least 1 argument, 0 given", get_active_function_name(TSRMLS_C));
; 		return;
; 	}

; 	if (!php_gtk_parse_args(1, "s", &name))
; 		return;

; 	signal_id = gtk_signal_lookup(name, GTK_OBJECT_TYPE(PHP_GTK_GET(this_ptr)));
; 	if (signal_id <= 0) {
; 		php_error(E_WARNING, "%s() can't find signal '%s' in class hierarchy",
; 				  get_active_function_name(TSRMLS_C), name);
; 		return;
; 	}

; 	query = gtk_signal_query(signal_id);
; 	if (ZEND_NUM_ARGS() < (int)query->nparams + 1) {
; 		php_error(E_WARNING, "%s() requires %d arguments for signal '%s', %d given",
; 				  get_active_function_name(TSRMLS_C), query->nparams, name, ZEND_NUM_ARGS()-1);
; 		g_free(query);
; 		return;
; 	}

; 	php_params = php_gtk_func_args_as_hash(ZEND_NUM_ARGS(), 1, ZEND_NUM_ARGS());
; 	params = g_new(GtkArg, query->nparams + 1);
; 	nparams = query->nparams;

; 	for (i = 0; i < nparams; i++) {
; 		params[i].type = query->params[i];
; 		params[i].name = NULL;
; 	}
; 	params[i].type = query->return_val;
; 	params[i].name = NULL;
; 	params[i].d.pointer_data = buf;
; 	g_free(query);

; 	if (!php_gtk_args_from_hash(params, nparams, php_params)) {
; 		zval_ptr_dtor(&php_params);
; 		g_free(params);
; 		return;
; 	}
; 	zval_ptr_dtor(&php_params);

; 	gtk_signal_emitv(PHP_GTK_GET(this_ptr), signal_id, params);
; 	ret = php_gtk_ret_as_value(&params[nparams]);
; 	g_free(params);
; 	if (ret) {
; 		*return_value = *ret;
; 		FREE_ZVAL(ret);
; 	}
; }
; %%
; override gtk_object_set
; PHP_FUNCTION(gtk_object_set)
; {
; 	zval *hash;
; 	GtkArg *arg;
; 	gint nargs;
; 	GtkObject *obj;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "a", &hash))
; 		return;

; 	obj = PHP_GTK_GET(this_ptr);
; 	arg = php_gtk_hash_as_args(hash, GTK_OBJECT_TYPE(obj), &nargs);
; 	if (!arg && nargs != 0)
; 		return;

; 	gtk_object_setv(obj, nargs, arg);
; 	g_free(arg);
; }
; %%
; override gtk_object_get
; PHP_FUNCTION(gtk_object_get)
; {
; 	char *name;
; 	GtkArg garg;
; 	zval *ret;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "s", &name))
; 		return;

; 	garg.type = GTK_TYPE_INVALID;
; 	garg.name = name;
; 	gtk_object_getv(PHP_GTK_GET(this_ptr), 1, &garg);

; 	if (garg.type == GTK_TYPE_INVALID) {
; 		php_error(E_WARNING, "%s(): invalid arg '%s'",
; 				  get_active_function_name(TSRMLS_C), name);
; 		return;
; 	}
	
; 	ret = php_gtk_arg_as_value(&garg);
; 	if (ret == NULL) {
; 		php_error(E_WARNING, "%s() couldn't translate type",
; 				  get_active_function_name(TSRMLS_C));
; 		return;
; 	}

; 	zval_add_ref(&ret);
; 	*return_value = *ret;
; 	FREE_ZVAL(ret);
; }
; %%
; override gtk_object_set_data
; PHP_FUNCTION(gtk_object_set_data)
; {
; 	char *key;
; 	zval *data;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "sV", &key, &data))
; 		return;

; 	zval_add_ref(&data);
; 	gtk_object_set_data_full(PHP_GTK_GET(this_ptr), key, data, php_gtk_destroy_notify);
; }
; %%
; override gtk_object_get_data
; PHP_FUNCTION(gtk_object_get_data)
; {
; 	char *key;
; 	zval *data;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "s", &key))
; 		return;

; 	data = gtk_object_get_data(PHP_GTK_GET(this_ptr), key);
; 	if (data) {
; 		*return_value = *data;
; 		zval_copy_ctor(return_value);
; 	}
; }

; %% }}}

; %% {{{ GtkRadioButton
; %%

; %%
; override gtk_radio_button_new
; PHP_FUNCTION(gtk_radio_button_new)
; {
; 	zval *php_group = NULL;
; 	gchar *text = NULL;
; 	GtkRadioButton *group = NULL;
; 	GtkObject *wrapped_obj = NULL;
; #ifdef PHP_WIN32
; 	gchar *utf8_text = NULL;
; #endif

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "|Ns", &php_group, gtk_radiobutton_ce, &text))
; 		return;

; 	if (php_group && Z_TYPE_P(php_group) != IS_NULL)
; 		group = GTK_RADIO_BUTTON(PHP_GTK_GET(php_group));

; 	if (!text) {
; 		if (!group)
; 			wrapped_obj = (GtkObject *)gtk_radio_button_new(NULL);
; 		else
; 			wrapped_obj = (GtkObject *)gtk_radio_button_new(group->group);
; 	} else {
; #ifdef PHP_WIN32
; 		utf8_text = g_convert(text, strlen(text), "UTF-8", GTK_G(codepage), NULL, NULL, NULL);
; 		if (!group)
; 			wrapped_obj = (GtkObject *)gtk_radio_button_new_with_label(NULL, utf8_text);
; 		else
; 			wrapped_obj = (GtkObject *)gtk_radio_button_new_with_label(group->group, utf8_text);
; 		if (utf8_text) g_free(utf8_text);
; #else
; 		if (!group)
; 			wrapped_obj = (GtkObject *)gtk_radio_button_new_with_label(NULL, text);
; 		else
; 			wrapped_obj = (GtkObject *)gtk_radio_button_new_with_label(group->group, text);
; #endif
; 	}

; 	if (!wrapped_obj) {
; 		php_error(E_WARNING, "%s(): could not create GtkRadioButton object",
; 				  get_active_function_name(TSRMLS_C));
; 		php_gtk_invalidate(this_ptr);
; 		return;
; 	}

; 	php_gtk_object_init(wrapped_obj, this_ptr);	
; }

; %%
; override gtk_radio_button_group
; PHP_FUNCTION(gtk_radio_button_group)
; {
; 	GtkRadioButton *button;
; 	GSList *list, *tmp;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), ""))
; 		return;

; 	button = GTK_RADIO_BUTTON(PHP_GTK_GET(this_ptr));

; 	array_init(return_value);
; 	list = gtk_radio_button_group(button);
; 	for (tmp = list; tmp; tmp = tmp->next) {
; 		add_next_index_zval(return_value, php_gtk_new(tmp->data));
; 	}
; }

; %%
; override gtk_radio_button_set_group
; PHP_FUNCTION(gtk_radio_button_set_group)
; {
; 	zval *php_button;
; 	GSList *list;

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "O", &php_button, gtk_radiobutton_ce))
; 		return;

; 	list = gtk_radio_button_group(GTK_RADIO_BUTTON(PHP_GTK_GET(php_button)));
; 	gtk_radio_button_set_group(GTK_RADIO_BUTTON(PHP_GTK_GET(this_ptr)), list);
; }

; %% }}}

; %% {{{ GtkRadioMenuItem
; %%

; %%
; override gtk_radio_menu_item_new
; PHP_FUNCTION(gtk_radio_menu_item_new)
; {
; 	zval *php_group = NULL;
; 	gchar *text = NULL;
; 	GtkRadioMenuItem *group = NULL;
; 	GtkObject *wrapped_obj = NULL;
; #ifdef PHP_WIN32
; 	gchar *utf8_text = NULL;
; #endif

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "|Ns", &php_group, gtk_radiomenuitem_ce, &text))
; 		return;

; 	if (php_group && Z_TYPE_P(php_group) != IS_NULL)
; 		group = GTK_RADIO_MENU_ITEM(PHP_GTK_GET(php_group));

; 	if (!text) {
; 		if (!group)
; 			wrapped_obj = (GtkObject *)gtk_radio_menu_item_new(NULL);
; 		else
; 			wrapped_obj = (GtkObject *)gtk_radio_menu_item_new(group->group);
; 	} else {
; #ifdef PHP_WIN32
; 		utf8_text = g_convert(text, strlen(text), "UTF-8", GTK_G(codepage), NULL, NULL, NULL);
; 		if (!group)
; 			wrapped_obj = (GtkObject *)gtk_radio_menu_item_new_with_label(NULL, utf8_text);
; 		else
; 			wrapped_obj = (GtkObject *)gtk_radio_menu_item_new_with_label(group->group, utf8_text);
; 		if (utf8_text) g_free(utf8_text);
; #else
; 		if (!group)
; 			wrapped_obj = (GtkObject *)gtk_radio_menu_item_new_with_label(NULL, text);
; 		else
; 			wrapped_obj = (GtkObject *)gtk_radio_menu_item_new_with_label(group->group, text);
; #endif
; 	}

; 	if (!wrapped_obj) {
; 		php_error(E_WARNING, "%s(): could not create GtkRadioMenuItem object",
; 				  get_active_function_name(TSRMLS_C));
; 		php_gtk_invalidate(this_ptr);
; 		return;
; 	}

; 	php_gtk_object_init(wrapped_obj, this_ptr);	
; }

; %%
; override gtk_radio_menu_item_group
; PHP_FUNCTION(gtk_radio_menu_item_group)
; {
; 	GtkRadioMenuItem *menu_item;
; 	GSList *list, *tmp;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), ""))
; 		return;

; 	menu_item = GTK_RADIO_MENU_ITEM(PHP_GTK_GET(this_ptr));

; 	array_init(return_value);
; 	list = gtk_radio_menu_item_group(menu_item);
; 	for (tmp = list; tmp; tmp = tmp->next) {
; 		add_next_index_zval(return_value, php_gtk_new(tmp->data));
; 	}
; }

; %%
; override gtk_radio_menu_item_set_group
; PHP_FUNCTION(gtk_radio_menu_item_set_group)
; {
; 	zval *php_menu_item;
; 	GSList *list;

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "O", &php_menu_item, gtk_radiomenuitem_ce))
; 		return;

; 	list = gtk_radio_menu_item_group(GTK_RADIO_MENU_ITEM(PHP_GTK_GET(php_menu_item)));
; 	gtk_radio_menu_item_set_group(GTK_RADIO_MENU_ITEM(PHP_GTK_GET(this_ptr)), list);
; }

; %% }}}

; %% {{{ GtkTable
; %%
; getprop GtkTable children
; 	GList *tmp;
; 	GList *children = GTK_TABLE(PHP_GTK_GET(object))->children;
; 	zend_overloaded_element *property;
; 	zend_llist_element *next = (*element)->next;
; 	int prop_index;

; 	if (next) {
; 		int i = 0;
; 		property = (zend_overloaded_element *)next->data;
; 		if (Z_TYPE_P(property) == OE_IS_ARRAY && Z_TYPE(property->element) == IS_LONG) {
; 			*element = next;
; 			prop_index = Z_LVAL(property->element);
; 			for (tmp = children, i = 0; tmp; tmp = tmp->next, i++) {
; 				if (i == prop_index) {
; 					*return_value = *php_gtk_table_child_new((GtkTableChild *)tmp->data);
; 					return;
; 				}
; 			}
; 		}
; 	} else {
; 		array_init(return_value);
; 		for (tmp = children; tmp; tmp = tmp->next) {
; 			add_next_index_zval(return_value, php_gtk_table_child_new((GtkTableChild *)tmp->data));
; 		}
; 	}
; %% }}}

; %% {{{ GtkToggleButton
; %%

; %%
; override gtk_toggle_button_new
; PHP_FUNCTION(gtk_toggle_button_new)
; {
; 	GtkObject *wrapped_obj;
; 	gchar *text = NULL;
; #ifdef PHP_WIN32
; 	gchar *utf8_text = NULL;
; #endif

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "|s", &text)) {
; 		php_gtk_invalidate(this_ptr);
; 		return;
; 	}

; 	if (text) {
; #ifdef PHP_WIN32
; 		utf8_text = g_convert(text, strlen(text), "UTF-8", GTK_G(codepage), NULL, NULL, NULL);
; 		wrapped_obj = (GtkObject *)gtk_toggle_button_new_with_label(utf8_text);
; 		if (utf8_text) g_free(utf8_text);
; #else
; 		wrapped_obj = (GtkObject *)gtk_toggle_button_new_with_label(text);
; #endif
; 	}
; 	else
; 		wrapped_obj = (GtkObject *)gtk_toggle_button_new();

; 	if (!wrapped_obj) {
; 		php_error(E_WARNING, "%s(): could not create GtkToggleButton object",
; 				  get_active_function_name(TSRMLS_C));
; 		php_gtk_invalidate(this_ptr);
; 		return;
; 	}

; 	php_gtk_object_init(wrapped_obj, this_ptr);
; }
; %% }}}

; %% {{{ GtkToolbar
; %%
; override gtk_toolbar_append_item

; static void gtk_toolbar_item_impl(INTERNAL_FUNCTION_PARAMETERS, int action)
; {
; 	gchar *text, *tooltip_text, *tooltip_priv_text;
; #ifdef PHP_WIN32
; 	gchar *utf8_text, *utf8_tooltip_text, *utf8_tooltip_priv_text;
; #endif
; 	zval *php_icon = NULL;
; 	zval *callback = NULL;
; 	zval *extra;
; 	zval *data;
; 	char *callback_filename;
; 	uint callback_lineno;
; 	GtkWidget *icon = NULL;
; 	GtkWidget *item = NULL;
; 	int position;

; 	NOT_STATIC_METHOD();

; 	if (action == 2) {
; 		if (!php_gtk_parse_args(6, "sssNiV", &text, &tooltip_text,
; 								&tooltip_priv_text, &php_icon, gtk_widget_ce, &position, &callback)) {
; 			return;
; 		}
; 	} else {
; 		if (!php_gtk_parse_args(5, "sssNV", &text, &tooltip_text,
; 								&tooltip_priv_text, &php_icon, gtk_widget_ce, &callback)) {
; 			return;
; 		}
; 	}

; #ifdef PHP_WIN32
; 	utf8_text 			   = g_convert(text, strlen(text), "UTF-8", GTK_G(codepage), NULL, NULL, NULL);
; 	utf8_tooltip_text 	   = g_convert(tooltip_text, strlen(tooltip_text), "UTF-8", GTK_G(codepage), NULL, NULL, NULL);
; 	utf8_tooltip_priv_text = g_convert(tooltip_priv_text, strlen(tooltip_priv_text), "UTF-8", GTK_G(codepage), NULL, NULL, NULL);
; 	text              = utf8_text;
; 	tooltip_text      = utf8_tooltip_text;
; 	tooltip_priv_text = utf8_tooltip_priv_text;
; #endif

; 	if (php_icon && Z_TYPE_P(php_icon) != IS_NULL) {
; 		icon = GTK_WIDGET(PHP_GTK_GET(php_icon));
; 	}

; 	switch (action) {
; 		case 0: /* append */
; 			item = gtk_toolbar_append_item(GTK_TOOLBAR(PHP_GTK_GET(this_ptr)), text, tooltip_text,
; 										   tooltip_priv_text, icon, NULL, NULL);
; 			break;

; 		case 1: /* prepend */
; 			item = gtk_toolbar_prepend_item(GTK_TOOLBAR(PHP_GTK_GET(this_ptr)), text, tooltip_text,
; 											tooltip_priv_text, icon, NULL, NULL);
; 			break;

; 		case 2: /* insert */
; 			item = gtk_toolbar_insert_item(GTK_TOOLBAR(PHP_GTK_GET(this_ptr)), text, tooltip_text,
; 										   tooltip_priv_text, icon, NULL, NULL, position);
; 			break;

; 		default:
; 			assert(0);
; 			break;
; 	}

; 	if (item) {
; 		callback_filename = zend_get_executed_filename(TSRMLS_C);
; 		callback_lineno = zend_get_executed_lineno(TSRMLS_C);
; 		extra = php_gtk_func_args_as_hash(ZEND_NUM_ARGS(), (action==2) ? 6 : 5, ZEND_NUM_ARGS());
; 		data = php_gtk_build_value("(VNisi)", callback, extra, 1, callback_filename, callback_lineno);

; 		gtk_signal_connect_full(GTK_OBJECT(item), "clicked", NULL,
; 								(GtkCallbackMarshal)php_gtk_callback_marshal,
; 								data, php_gtk_destroy_notify, FALSE, FALSE);
; 	}

; #ifdef PHP_WIN32
; 	g_free(utf8_text);
; 	g_free(utf8_tooltip_text);
; 	g_free(utf8_tooltip_priv_text);
; #endif

;     PHP_GTK_SEPARATE_RETURN(return_value, php_gtk_new((GtkObject *)item));
; }

; PHP_FUNCTION(gtk_toolbar_append_item)
; {
; 	gtk_toolbar_item_impl(INTERNAL_FUNCTION_PARAM_PASSTHRU, 0);
; }

; %%
; override gtk_toolbar_prepend_item
; PHP_FUNCTION(gtk_toolbar_prepend_item)
; {
; 	gtk_toolbar_item_impl(INTERNAL_FUNCTION_PARAM_PASSTHRU, 1);
; }

; %%
; override gtk_toolbar_insert_item
; PHP_FUNCTION(gtk_toolbar_insert_item)
; {
; 	gtk_toolbar_item_impl(INTERNAL_FUNCTION_PARAM_PASSTHRU, 2);
; }

; %%
; override gtk_toolbar_append_element

; static void gtk_toolbar_element_impl(INTERNAL_FUNCTION_PARAMETERS, int action)
; {
; 	gchar *text, *tooltip_text, *tooltip_priv_text;
; #ifdef PHP_WIN32
; 	gchar *utf8_text, *utf8_tooltip_text, *utf8_tooltip_priv_text;
; #endif
; 	zval *php_elem_type = NULL;
; 	zval *php_widget = NULL;
; 	zval *php_icon = NULL;
; 	zval *callback = NULL;
; 	zval *extra;
; 	zval *data;
; 	char *callback_filename;
; 	uint callback_lineno;
; 	GtkWidget *icon = NULL;
; 	GtkWidget *item = NULL;
; 	GtkWidget *widget = NULL;
; 	GtkToolbarChildType elem_type;
; 	int position;

; 	NOT_STATIC_METHOD();

; 	if (action == 2) {
; 		if (!php_gtk_parse_args(8, "VNsssNiV", &php_elem_type, &php_widget, gtk_widget_ce, &text, &tooltip_text,
; 								&tooltip_priv_text, &php_icon, gtk_widget_ce, &position, &callback)) {
; 			return;
; 		}
; 	} else {
; 		if (!php_gtk_parse_args(7, "VNsssNV", &php_elem_type, &php_widget, gtk_widget_ce, &text, &tooltip_text,
; 								&tooltip_priv_text, &php_icon, gtk_widget_ce, &callback)) {
; 			return;
; 		}
; 	}

; #ifdef PHP_WIN32
; 	utf8_text 			   = g_convert(text, strlen(text), "UTF-8", GTK_G(codepage), NULL, NULL, NULL);
; 	utf8_tooltip_text 	   = g_convert(tooltip_text, strlen(tooltip_text), "UTF-8", GTK_G(codepage), NULL, NULL, NULL);
; 	utf8_tooltip_priv_text = g_convert(tooltip_priv_text, strlen(tooltip_priv_text), "UTF-8", GTK_G(codepage), NULL, NULL, NULL);
; 	text              = utf8_text;
; 	tooltip_text      = utf8_tooltip_text;
; 	tooltip_priv_text = utf8_tooltip_priv_text;
; #endif

; 	if (php_elem_type && !php_gtk_get_enum_value(GTK_TYPE_TOOLBAR_CHILD_TYPE, php_elem_type, (gint *)&elem_type)) {
; 		return;
; 	}

; 	if (php_widget && Z_TYPE_P(php_widget) != IS_NULL) {
; 		widget = GTK_WIDGET(PHP_GTK_GET(php_widget));
; 	}

; 	if (php_icon && Z_TYPE_P(php_icon) != IS_NULL) {
; 		icon = GTK_WIDGET(PHP_GTK_GET(php_icon));
; 	}

; 	if (elem_type == GTK_TOOLBAR_CHILD_BUTTON ||
; 		elem_type == GTK_TOOLBAR_CHILD_TOGGLEBUTTON ||
; 		elem_type == GTK_TOOLBAR_CHILD_SPACE) {
; 		widget = NULL;
; 	}

; 	switch (action) {
; 		case 0: /* append */
; 			item = gtk_toolbar_append_element(GTK_TOOLBAR(PHP_GTK_GET(this_ptr)), elem_type, widget, text,
; 											  tooltip_text, tooltip_priv_text, icon, NULL, NULL);
; 			break;

; 		case 1: /* prepend */
; 			item = gtk_toolbar_prepend_element(GTK_TOOLBAR(PHP_GTK_GET(this_ptr)), elem_type, widget, text,
; 											   tooltip_text, tooltip_priv_text, icon, NULL, NULL);
; 			break;

; 		case 2: /* insert */
; 			item = gtk_toolbar_insert_element(GTK_TOOLBAR(PHP_GTK_GET(this_ptr)), elem_type, widget, text,
; 											  tooltip_text, tooltip_priv_text, icon, NULL, NULL, position);
; 			break;

; 		default:
; 			assert(0);
; 			break;
; 	}

; 	if (item &&
; 		(elem_type == GTK_TOOLBAR_CHILD_BUTTON ||
; 		 elem_type == GTK_TOOLBAR_CHILD_TOGGLEBUTTON ||
; 		 elem_type == GTK_TOOLBAR_CHILD_RADIOBUTTON)) {

; 		callback_filename = zend_get_executed_filename(TSRMLS_C);
; 		callback_lineno = zend_get_executed_lineno(TSRMLS_C);
; 		extra = php_gtk_func_args_as_hash(ZEND_NUM_ARGS(), (action==2) ? 8 : 7, ZEND_NUM_ARGS());
; 		data = php_gtk_build_value("(VNisi)", callback, extra, 1, callback_filename, callback_lineno);

; 		gtk_signal_connect_full(GTK_OBJECT(item), "clicked", NULL,
; 								(GtkCallbackMarshal)php_gtk_callback_marshal,
; 								data, php_gtk_destroy_notify, FALSE, FALSE);
; 	}

; #ifdef PHP_WIN32
; 	g_free(utf8_text);
; 	g_free(utf8_tooltip_text);
; 	g_free(utf8_tooltip_priv_text);
; #endif

; 	PHP_GTK_SEPARATE_RETURN(return_value, php_gtk_new((GtkObject *)item));
; }

; PHP_FUNCTION(gtk_toolbar_append_element)
; {
; 	gtk_toolbar_element_impl(INTERNAL_FUNCTION_PARAM_PASSTHRU, 0);
; }

; %%
; override gtk_toolbar_prepend_element
; PHP_FUNCTION(gtk_toolbar_prepend_element)
; {
; 	gtk_toolbar_element_impl(INTERNAL_FUNCTION_PARAM_PASSTHRU, 1);
; }

; %%
; override gtk_toolbar_insert_element
; PHP_FUNCTION(gtk_toolbar_insert_element)
; {
; 	gtk_toolbar_element_impl(INTERNAL_FUNCTION_PARAM_PASSTHRU, 2);
; }
; %% }}}

; %% {{{ GtkTreeItem
; %%

; %%
; override gtk_tree_item_new
; PHP_FUNCTION(gtk_tree_item_new)
; {
; 	GtkObject *wrapped_obj;
; 	gchar *text = NULL;
; #ifdef PHP_WIN32
; 	gchar *utf8_text = NULL;
; #endif

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "|s", &text)) {
; 		php_gtk_invalidate(this_ptr);
; 		return;
; 	}

; 	if (text) {
; #ifdef PHP_WIN32
; 		utf8_text = g_convert(text, strlen(text), "UTF-8", GTK_G(codepage), NULL, NULL, NULL);
; 		wrapped_obj = (GtkObject *)gtk_tree_item_new_with_label(utf8_text);
; 		if (utf8_text) g_free(utf8_text);
; #else
; 		wrapped_obj = (GtkObject *)gtk_tree_item_new_with_label(text);
; #endif
; 	}
; 	else
; 		wrapped_obj = (GtkObject *)gtk_tree_item_new();

; 	if (!wrapped_obj) {
; 		php_error(E_WARNING, "%s(): could not create GtkTreeItem object",
; 				get_active_function_name(TSRMLS_C));
; 		php_gtk_invalidate(this_ptr);
; 		return;
; 	}

; 	php_gtk_object_init(wrapped_obj, this_ptr);
; }
; %% }}}

(define (get-hash-arg name value)
   (let ((value (maybe-unbox value)))
      (if (php-hash? value)
	  value
	  (begin
	     (php-warning "Argument " name " should be an array.")
	     (make-php-hash)))))

(defmethod GtkWidget (drag_dest_set flags targets actions)
   (let ((flags (gtk-flag-value 'GTK_TYPE_DEST_DEFAULTS flags))
	 (actions (gtk-flag-value 'GTK_TYPE_GDK_DRAG_ACTION actions))
	 (targets (get-hash-arg 'targets targets)))
      (let ((c-targets (pragma::GtkTargetEntry* "g_new(GtkTargetEntry, $1)"
						(php-hash-size targets))))
	 (let ((i 0))
	    (php-hash-for-each targets
	       (lambda (k v)
		  (let ((target-values (if (php-hash? v)
					   (php-hash->list v)
					   '())))
;		     (map display-circle `("one iteration, key is " ,k " value is " ,v "\n"))
		     (unless (= 3 (length target-values))
			(php-warning "unable to parse target " i)
			(return FALSE))
		     (let ((target::string (mkstr (car target-values)))
			   (flags::int (mkfixnum (cadr target-values)))
			   (info::int (mkfixnum (caddr target-values)))
			   (c-targets::GtkTargetEntry* c-targets)
			   (i::int i))
;			(print "target " target " flags " flags " info " info)
			(pragma "$1[$2].target = $3" c-targets i target)
			(pragma "$1[$2].flags = $3" c-targets i flags)
			(pragma "$1[$2].info = $3" c-targets i info))
		     ;; XXX note that we set the outer i
		     (set! i (+ i 1)))))
;	    (print "setting drag dest " (GTK_WIDGET (gtk-object $this)) ", " flags ", " c-targets ", " actions)
	    (gtk_drag_dest_set (GTK_WIDGET (gtk-object $this)) flags c-targets i actions)
	    (let ((c-targets::GtkTargetEntry* c-targets))
	       (pragma "g_free($1)" c-targets)
	       TRUE) ))))

		     
		     

; %% {{{ GtkWidget
; %%
; override gtk_drag_dest_set
; PHP_FUNCTION(gtk_drag_dest_set)
; {
; 	zval *php_flags, *php_targets, *php_actions;
; 	zval **item;
; 	GtkDestDefaults flags;
; 	GdkDragAction actions;
; 	GtkTargetEntry *targets;
; 	int i;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "VaV", &php_flags, &php_targets,
; 							&php_actions))
; 		return;

; 	if (!php_gtk_get_flag_value(GTK_TYPE_DEST_DEFAULTS, php_flags, (gint *)&flags))
; 		return;

; 	if (!php_gtk_get_flag_value(GTK_TYPE_GDK_DRAG_ACTION, php_actions, (gint *)&actions))
; 		return;

; 	targets = g_new(GtkTargetEntry, zend_hash_num_elements(Z_ARRVAL_P(php_targets)));

; 	for (zend_hash_internal_pointer_reset(Z_ARRVAL_P(php_targets)), i = 0;
; 		 zend_hash_get_current_data(Z_ARRVAL_P(php_targets), (void **)&item) == SUCCESS;
; 		 zend_hash_move_forward(Z_ARRVAL_P(php_targets)), i++) {
; 		if (Z_TYPE_PP(item) != IS_ARRAY ||
; 			!php_gtk_parse_args_hash_quiet(*item, "sii", &targets[i].target,
; 										   &targets[i].flags, &targets[i].info)) {
; 			php_error(E_WARNING, "%s() was unable to parse target #%d in the list of targets", get_active_function_name(TSRMLS_C), i+1);
; 			g_free(targets);
; 			return;
; 		}
; 	}

; 	gtk_drag_dest_set(GTK_WIDGET(PHP_GTK_GET(this_ptr)), flags, targets, i, actions);
; 	g_free(targets);
; }


(defmethod GtkWidget (drag_source_set sbmask targets actions)
   (let ((sbmask (gtk-flag-value 'GTK_TYPE_GDK_MODIFIER_TYPE sbmask))
	 (actions (gtk-flag-value 'GTK_TYPE_GDK_DRAG_ACTION actions))
	 (targets (get-hash-arg 'targets targets)))
      (let ((c-targets (pragma::GtkTargetEntry* "g_new(GtkTargetEntry, $1)"
						(php-hash-size targets))))
	 (let ((i 0))
	    (php-hash-for-each targets
	       (lambda (k v)
;		  (map display-circle `("one (source) iteration, key is " ,k " value is " ,v "\n"))
				     
		  (let ((target-values (if (php-hash? v)
					   (php-hash->list v)
					   '())))
		     (unless (= 3 (length target-values))
			(php-warning "unable to parse target " i "  in the list of targets")
			(return FALSE))
		     (let ((target::string (mkstr (car target-values)))
			   (flags::int (mkfixnum (cadr target-values)))
			   (info::int (mkfixnum (caddr target-values)))
			   (c-targets::GtkTargetEntry* c-targets)
			   (i::int i))
;			(print "source target " target " flags " flags " info " info)
			(pragma "$1[$2].target = $3" c-targets i target)
			(pragma "$1[$2].flags = $3" c-targets i flags)
			(pragma "$1[$2].info = $3" c-targets i info))
		     ;; XXX note that we set the outer i
		     (set! i (+ i 1)))))
;	    (print "setting drag source " (GTK_WIDGET (gtk-object $this)) ", " sbmask ", " c-targets ", " actions)
	    (gtk_drag_source_set (GTK_WIDGET (gtk-object $this)) sbmask c-targets i actions)

	    (let ((c-targets::GtkTargetEntry* c-targets))
	       (pragma "g_free($1)" c-targets)
	       TRUE)))))


; override gtk_drag_source_set
; PHP_FUNCTION(gtk_drag_source_set)
; {
; 	zval *php_sbmask, *php_targets, *php_actions;
; 	zval **item;
; 	GdkModifierType sbmask;
; 	GdkDragAction actions;
; 	GtkTargetEntry *targets;
; 	int i;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "VaV", &php_sbmask, &php_targets,
; 							&php_actions))
; 		return;

; 	if (!php_gtk_get_flag_value(GTK_TYPE_GDK_MODIFIER_TYPE, php_sbmask, (gint *)&sbmask))
; 		return;

; 	if (!php_gtk_get_flag_value(GTK_TYPE_GDK_DRAG_ACTION, php_actions, (gint *)&actions))
; 		return;

; 	targets = g_new(GtkTargetEntry, zend_hash_num_elements(Z_ARRVAL_P(php_targets)));

; 	for (zend_hash_internal_pointer_reset(Z_ARRVAL_P(php_targets)), i = 0;
; 		 zend_hash_get_current_data(Z_ARRVAL_P(php_targets), (void **)&item) == SUCCESS;
; 		 zend_hash_move_forward(Z_ARRVAL_P(php_targets)), i++) {
; 		if (Z_TYPE_PP(item) != IS_ARRAY ||
; 			!php_gtk_parse_args_hash_quiet(*item, "sii", &targets[i].target,
; 										   &targets[i].flags, &targets[i].info)) {
; 			php_error(E_WARNING, "%s() was unable to parse target #%d in the list of targets", get_active_function_name(TSRMLS_C), i+1);
; 			g_free(targets);
; 			return;
; 		}
; 	}

; 	gtk_drag_source_set(GTK_WIDGET(PHP_GTK_GET(this_ptr)), sbmask, targets, i, actions);
; 	g_free(targets);
; }
; %%
; override gtk_drag_begin
; PHP_FUNCTION(gtk_drag_begin)
; {
; 	zval *php_targets, *php_actions, *event;
; 	zval *php_ret, **item;
; 	GdkDragAction actions;
; 	GtkTargetEntry *tents;
; 	GtkTargetList *targets;
; 	GdkDragContext *context;
; 	gint button, i;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "aViO", &php_targets, &php_actions,
; 							&button, &event, gdk_event_ce))
; 		return;

; 	if (!php_gtk_get_flag_value(GTK_TYPE_GDK_DRAG_ACTION, php_actions, (gint *)&actions))
; 		return;

; 	tents = g_new(GtkTargetEntry, zend_hash_num_elements(Z_ARRVAL_P(php_targets)));

; 	for (zend_hash_internal_pointer_reset(Z_ARRVAL_P(php_targets)), i = 0;
; 		 zend_hash_get_current_data(Z_ARRVAL_P(php_targets), (void **)&item) == SUCCESS;
; 		 zend_hash_move_forward(Z_ARRVAL_P(php_targets)), i++) {
; 		if (Z_TYPE_PP(item) != IS_ARRAY ||
; 			!php_gtk_parse_args_hash_quiet(*item, "sii", &tents[i].target,
; 										   &tents[i].flags, &tents[i].info)) {
; 			php_error(E_WARNING, "%s() was unable to parse target #%d in the list of targets", get_active_function_name(TSRMLS_C), i+1);
; 			g_free(tents);
; 			return;
; 		}
; 	}

; 	targets = gtk_target_list_new(tents, i);
; 	g_free(tents);
; 	context = gtk_drag_begin(GTK_WIDGET(PHP_GTK_GET(this_ptr)), targets, actions, button, PHP_GDK_EVENT_GET(event));
; 	gtk_target_list_unref(targets);

; 	php_ret = php_gdk_drag_context_new(context);
; 	SEPARATE_ZVAL(&php_ret);
; 	*return_value = *php_ret;
; }
; %%
; override gtk_widget_size_request
; PHP_FUNCTION(gtk_widget_size_request)
; {   
; 	zval *ret;
;     GtkRequisition requisition;

;     NOT_STATIC_METHOD();

;     if (!php_gtk_parse_args(ZEND_NUM_ARGS(), ""))
;         return;

;     gtk_widget_size_request(GTK_WIDGET(PHP_GTK_GET(this_ptr)), &requisition);

; 	ret = php_gtk_requisition_new(&requisition);
; 	*return_value = *ret;
; 	FREE_ZVAL(ret);
; }
; %%
; override gtk_widget_get_child_requisition
; PHP_FUNCTION(gtk_widget_get_child_requisition)
; {   
; 	zval *ret;
;     GtkRequisition requisition;

;     NOT_STATIC_METHOD();

;     if (!php_gtk_parse_args(ZEND_NUM_ARGS(), ""))
;         return;

;     gtk_widget_get_child_requisition(GTK_WIDGET(PHP_GTK_GET(this_ptr)), &requisition);

; 	ret = php_gtk_requisition_new(&requisition);
; 	*return_value = *ret;
; 	FREE_ZVAL(ret);
; }
; %%
; override gtk_widget_intersect
; PHP_FUNCTION(gtk_widget_intersect)
; {
; 	zval *php_area;
; 	GdkRectangle area, intersection;
	
; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "O", &php_area, gdk_rectangle_ce))
; 		return;

; 	php_gdk_rectangle_get(php_area, &area);
; 	if (gtk_widget_intersect(GTK_WIDGET(PHP_GTK_GET(this_ptr)), &area, &intersection)) {
; 		zval *ret;

; 		ret= php_gdk_rectangle_new(&intersection);
; 		*return_value = *ret;
; 		FREE_ZVAL(ret);
; 	} else {
; 		RETURN_FALSE;
; 	}
; }
; %%
; override gtk_font_selection_dialog_set_filter
; PHP_FUNCTION(gtk_font_selection_dialog_set_filter)
; {
; 	set_filter(INTERNAL_FUNCTION_PARAM_PASSTHRU, 0);
; }
; %%
; override gtk_font_selection_set_filter
; /* Convert a ZVAL to an array of gchar strings terminated with NULL */
; int php_gtk_array_to_gchar_array(zval *zvalue, gchar ***gchar_array)
; {
; 	/* If either no value was passed or its the PHP NULL value, return NULL
; 	 * too. This is not an error but just an empty gchar array. */
; 	if (zvalue == NULL || Z_TYPE_P(zvalue) == IS_NULL) {
; 		*gchar_array = NULL;
; 		return 1;
; 	}

; 	/* Even when a normal string is passed we create an array with just one
; 	 * entry so you don't have to write array('string') just for one entry. */
; 	if (Z_TYPE_P(zvalue) == IS_STRING) {
; 		*gchar_array = emalloc(sizeof(gchar *) * 2);
; 		(*gchar_array)[0] = estrndup(Z_STRVAL_P(zvalue), Z_STRLEN_P(zvalue));
; 		(*gchar_array)[1] = NULL;
; 		return 1;
; 	/* If the array is empty, just return NULL (see above for NULL value).
; 	 * Else reset the internal array pointer and iterate through its element,
; 	 * separate and convert them to strings and finally build the gchar array. */
; 	} else if (Z_TYPE_P(zvalue) == IS_ARRAY) {
; 		HashTable *array;
; 		zval **temp_text;
; 		int i = 0;

; 		array = HASH_OF(zvalue);
; 		if (zend_hash_num_elements(array) == 0) {
; 			*gchar_array = NULL;
; 			return 1;
; 		}
; 		*gchar_array = emalloc(sizeof(gchar *) * (zend_hash_num_elements(array) + 1));
; 		i = 0;
; 		zend_hash_internal_pointer_reset(array);
; 		while (zend_hash_get_current_data(array, (void**)&temp_text) == SUCCESS) {
; 			convert_to_string_ex(temp_text);
; 			(*gchar_array)[i++] = estrndup(Z_STRVAL_PP(temp_text), Z_STRLEN_PP(temp_text));
; 			zend_hash_move_forward(array);
; 		}
; 		(*gchar_array)[i] = NULL;
; 		return 1;
; 	}
; 	/* Error indication */
; 	return 0;
; }

; /* Free a NULL terminated list of gchar pointers */
; void php_gtk_free_gchar_array(gchar **gchar_array)
; {
; 	int i = 0;
; 	while (gchar_array[i]) {
; 		efree(gchar_array[i++]);
; 	}
; }

; /* Simply traverse the array and free what is available. If you know you haven't allocated
;  * all of the entries you can pass the actual number of entries allocated; else just
;  * pass the maximum size (but be sure to have proper initialized the array to 0 first). */
; void php_gtk_free_gchar_ptr_array(gchar ***gchar_ptr_array, int num_elements)
; {
; 	int i;

; 	for (i = 0; i < num_elements; i++) {
; 		if (gchar_ptr_array[i]) {
; 			php_gtk_free_gchar_array(gchar_ptr_array[i]);
; 			efree(gchar_ptr_array[i]);
; 		}
; 	}
; 	efree(gchar_ptr_array);
; }

; static void set_filter(INTERNAL_FUNCTION_PARAMETERS, int which)
; {
; 	zval *php_filter_type,					/* ZVAL of the GTK+ enum; must be ZVAL so it can
; 											   be passed to php_gtk_get_enum_value */
; 		 *php_font_type = NULL,				/* The same as above; but since its optional we
; 											   default it to NULL and check for this later */
; 		 *php_args[6];						/* The rest of the parameters passed to the method,
; 											   stored in an array for loop traversion */
; 	GtkFontFilterType filter_type;			/* The real filer type we get back from php_gtk_get_enum_value
; 											   and pass to the real GTK+ function */
; 	GtkFontType font_type = GTK_FONT_ALL;	/* Again, the same, but with a default value so we don't need
; 											   to specify it if we don't explicetely need it */
; 	gchar ***parameters;					/* The parameters we build during runtime to be passed to
; 											   the real GTK+ function */
; 	int i, num_parameters = 6;				/* The number of parameters; could be a constant */

; 	NOT_STATIC_METHOD();

; 	parameters = ecalloc(sizeof(gchar *), num_parameters);	/* Allocate the memory for the parameters
; 															   we build and initialize the memory to 0 */
; 	memset(php_args, 0, sizeof(zval *) * num_parameters);	/* The same is true for the ZVAL array */

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "V|VVVVVVV", &php_filter_type, &php_font_type,
; 							&(php_args[0]), &(php_args[1]), &(php_args[2]),
; 							&(php_args[3]), &(php_args[4]), &(php_args[5]))) {
; 		return;
; 	}

; 	/* See if we got a valid enum value */
; 	if (!php_gtk_get_enum_value(GTK_TYPE_FONT_FILTER_TYPE, php_filter_type, (gint *)&filter_type)) {
; 		return;
; 	}

; 	/* See if we got a valid enum value; this one is optional and has a
; 	 * default value */
; 	if (php_font_type && !php_gtk_get_enum_value(GTK_TYPE_FONT_TYPE, php_font_type, (gint *)&font_type)) {
; 		return;
; 	}

; 	/* Process each parameter passe after the two enums and see if we can
; 	 * build a list of char pointers of it. Single strings are converted to an
; 	 * array too. NULL is also valid, in which case we just set the parameter
; 	 * to NULL. */
; 	for (i = 0; i < num_parameters; i++) {
; 		if (!php_gtk_array_to_gchar_array(php_args[i], &(parameters[i]))) {
; 			php_error(E_WARNING, "%s() expected argument %d to be NULL, string or array of strings; %s given",
; 					  get_active_function_name(TSRMLS_C), 3 + i, php_gtk_zval_type_name(php_args[i]));
; 			php_gtk_free_gchar_ptr_array(parameters, i - 1);
; 			return;
; 		}
; 	}

; 	/* Call the GTK+ function */
; 	switch( which) {
; 		case 0:
; 			gtk_font_selection_dialog_set_filter(GTK_FONT_SELECTION_DIALOG(PHP_GTK_GET(this_ptr)),
; 												 filter_type, font_type, 
; 												 parameters[0], parameters[1], parameters[2],
; 												 parameters[3], parameters[4], parameters[5]);
; 			break;
; 		case 1:
; 			gtk_font_selection_set_filter(GTK_FONT_SELECTION(PHP_GTK_GET(this_ptr)),
; 										  filter_type, font_type, 
; 										  parameters[0], parameters[1], parameters[2],
; 										  parameters[3], parameters[4], parameters[5]);
; 			break;
; 		default:
; 			php_error(E_WARNING, "%s() internal error, don't know which subfunction (%d) to call",
; 					  get_active_function_name(TSRMLS_C), which);
; 			/* return missing intentionally */
; 	}

; 	/* Free the parameters we previously allocated */
; 	php_gtk_free_gchar_ptr_array(parameters, num_parameters);
; }

; PHP_FUNCTION(gtk_font_selection_set_filter)
; {
; 	set_filter(INTERNAL_FUNCTION_PARAM_PASSTHRU, 1);
; }
; %%
; override gtk_button_box_get_child_size_default
; PHP_FUNCTION(gtk_button_box_get_child_size_default)
; {
; 	gint min_width, min_height;

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "")) {
; 		return;
; 	}

; 	gtk_button_box_get_child_size_default(&min_width, &min_height);
; 	array_init(return_value);
; 	add_next_index_long(return_value, min_width);
; 	add_next_index_long(return_value, min_height);
; }
; %%
; override gtk_button_box_get_child_ipadding_default
; PHP_FUNCTION(gtk_button_box_get_child_ipadding_default)
; {
; 	gint ipad_x, ipad_y;

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "")) {
; 		return;
; 	}

; 	gtk_button_box_get_child_ipadding_default(&ipad_x, &ipad_y);
; 	array_init(return_value);
; 	add_next_index_long(return_value, ipad_x);
; 	add_next_index_long(return_value, ipad_y);
; }
; %%
; override gtk_widget_get_pointer
; PHP_FUNCTION(gtk_widget_get_pointer)
; {
; 	gint x, y;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "")) {
; 		return;
; 	}

; 	gtk_widget_get_pointer(GTK_WIDGET(PHP_GTK_GET(this_ptr)), &x, &y);
; 	array_init(return_value);
; 	add_next_index_long(return_value, x);
; 	add_next_index_long(return_value, y);
; }




;; ==========================================




;; this would be handled adequately by the generated method, except
;; for the windows codepage stuff.
(defmethod GtkCTree (insert_node parent sibling text spacing pixmap_closed mask_closed pixmap_opened mask_opened is_leaf expanded)
   (let (($this::GtkCTree*
	  (if (php-null? (maybe-unbox $this))
              (pragma::GtkCTree* "NULL")
              (GTK_CTREE
	       (gtk-object/safe 'GtkCTree $this return))))
	 (parent::GtkCTreeNode*
	  (if (php-null? (maybe-unbox parent))
              (pragma::GtkCTreeNode* "NULL")
              (gtk-object/safe 'GtkCTreeNode parent return)))
	 (sibling::GtkCTreeNode*
	  (if (php-null? (maybe-unbox sibling))
              (pragma::GtkCTreeNode* "NULL")
              (gtk-object/safe 'GtkCTreeNode sibling return)))
	 ;; this is the codepage stuff he's on about :)
	 (text::string* ;(php-hash->string* text))
	  (string-list->string* (map convert-to-utf8 (php-hash->list (maybe-unbox text)))))
	 (spacing::int (mkfixnum spacing))
	 (pixmap_closed::GdkPixmap*
	  (if (php-null? (maybe-unbox pixmap_closed))
              (pragma::GdkPixmap* "NULL")
              (gtk-object/safe 'GdkPixmap pixmap_closed return)))
	 (mask_closed::GdkBitmap*
	  (if (php-null? (maybe-unbox mask_closed))
              (pragma::GdkBitmap* "NULL")
              (gtk-object/safe 'GdkBitmap mask_closed return)))
	 (pixmap_opened::GdkPixmap*
	  (if (php-null? (maybe-unbox pixmap_opened))
              (pragma::GdkPixmap* "NULL")
              (gtk-object/safe 'GdkPixmap pixmap_opened return)))
	 (mask_opened::GdkBitmap*
	  (if (php-null? (maybe-unbox mask_opened))
              (pragma::GdkBitmap* "NULL")
              (gtk-object/safe 'GdkBitmap mask_opened return)))
	 (is_leaf::bool (convert-to-boolean is_leaf))
	 (expanded::bool (convert-to-boolean expanded)))
      (gtk-wrapper-new
       'GtkCTreeNode
       (pragma::GtkCTreeNode*
	"gtk_ctree_insert_node($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)"
	$this
	parent
	sibling
	text
	spacing
	pixmap_closed
	mask_closed
	pixmap_opened
	mask_opened
	is_leaf
	expanded))))
;; pretty sure this one is handled adequately by the generated method.
;; The only thing we're missing is the nice error message when the
;; hash size != the number of columns.
; override gtk_ctree_insert_node
; PHP_FUNCTION(gtk_ctree_insert_node)
; {
; 	zval *php_parent, *php_sibling, *php_text,
; 		 *php_pixmap_closed, *php_pixmap_opened,
; 		 *php_mask_closed, *php_mask_opened, **temp_text;
; 	zval *php_ret;
; 	gint spacing, columns, i;
; 	zend_bool is_leaf, expanded;
; 	GtkCTreeNode *parent = NULL, *sibling = NULL, *ret;
; 	GdkPixmap *pixmap_closed = NULL, *pixmap_opened = NULL;
; 	GdkBitmap *mask_closed = NULL, *mask_opened = NULL;
; 	GtkCTree *tree;
; 	gchar **text = NULL;
; 	HashTable *target_hash;
; #ifdef PHP_WIN32
; 	gchar * utf8_text = NULL;
; #endif

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "NNa/iNNNNbb", &php_parent,
; 							gtk_ctree_node_ce, &php_sibling, gtk_ctree_node_ce,
; 							&php_text, &spacing, &php_pixmap_closed,
; 							gdk_pixmap_ce, &php_mask_closed, gdk_bitmap_ce,
; 							&php_pixmap_opened, gdk_pixmap_ce, &php_mask_opened,
; 							gdk_bitmap_ce, &is_leaf, &expanded))
; 		return;

; 	target_hash = HASH_OF(php_text);
; 	tree = GTK_CTREE(PHP_GTK_GET(this_ptr));
; 	columns = GTK_CLIST(tree)->columns;
; 	if (zend_hash_num_elements(target_hash) != columns) {
; 		php_error(E_WARNING, "%s(): the text array size (%d) does not match the number of columns in the ctree (%d)", get_active_function_name(TSRMLS_C), zend_hash_num_elements(target_hash), columns);
; 		return;
; 	}
; 	if (Z_TYPE_P(php_parent) != IS_NULL)
; 		parent			= PHP_GTK_CTREE_NODE_GET(php_parent);
; 	if (Z_TYPE_P(php_sibling) != IS_NULL)
; 		sibling			= PHP_GTK_CTREE_NODE_GET(php_sibling);
; 	if (Z_TYPE_P(php_pixmap_closed) != IS_NULL)
; 		pixmap_closed	= PHP_GDK_PIXMAP_GET(php_pixmap_closed);
; 	if (Z_TYPE_P(php_mask_closed) != IS_NULL)
; 		mask_closed		= PHP_GDK_BITMAP_GET(php_mask_closed);
; 	if (Z_TYPE_P(php_pixmap_opened) != IS_NULL)
; 		pixmap_opened	= PHP_GDK_PIXMAP_GET(php_pixmap_opened);
; 	if (Z_TYPE_P(php_mask_opened) != IS_NULL)
; 		mask_opened		= PHP_GDK_BITMAP_GET(php_mask_opened);

; 	text = emalloc(sizeof(gchar *) * columns);
; 	i = 0;
; 	zend_hash_internal_pointer_reset(target_hash);
; 	while (zend_hash_get_current_data(target_hash, (void **)&temp_text) == SUCCESS) {
; 		convert_to_string_ex(temp_text);
; #ifdef PHP_WIN32
; 		utf8_text = g_convert(Z_STRVAL_PP(temp_text), Z_STRLEN_PP(temp_text), "UTF-8", GTK_G(codepage), NULL, NULL, NULL);
; 		text[i++] = utf8_text;
; #else
; 		text[i++] = estrndup(Z_STRVAL_PP(temp_text), Z_STRLEN_PP(temp_text));
; #endif
; 		zend_hash_move_forward(target_hash);
; 	}

; 	ret = gtk_ctree_insert_node(tree, parent, sibling, text, (guint8)spacing,
; 								pixmap_closed, mask_closed, pixmap_opened,
; 								mask_opened, is_leaf, expanded);
; 	efree(text);
; 	php_ret = php_gtk_ctree_node_new(ret);
; 	SEPARATE_ZVAL(&php_ret);
; 	*return_value = *php_ret;
; }


;;;; constructor.. we overrode it anyway
; %% {{{ GtkCheckButton
; %%

; %%
; override gtk_check_button_new
; PHP_FUNCTION(gtk_check_button_new)
; {
; 	char *label = NULL;
; 	GtkObject *wrapped_obj;
; #ifdef PHP_WIN32
; 	gchar *utf8_label = NULL;
; #endif

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "|s", &label)) {
; 		php_gtk_invalidate(this_ptr);
; 		return;
; 	}

; 	if (label) {
; #ifdef PHP_WIN32
; 		utf8_label = g_convert(label, strlen(label), "UTF-8", GTK_G(codepage), NULL, NULL, NULL);
; 		wrapped_obj = (GtkObject *)gtk_check_button_new_with_label(utf8_label);
; 		if (utf8_label) g_free(utf8_label);
; #else
; 		wrapped_obj = (GtkObject *)gtk_check_button_new_with_label(label);		
; #endif
; 	}
;     else    
; 		wrapped_obj = (GtkObject *)gtk_check_button_new();
; 	if (!wrapped_obj) {
; 		php_error(E_WARNING, "%s(): could not create GtkCheckButton object",
; 				  get_active_function_name(TSRMLS_C));
; 		php_gtk_invalidate(this_ptr);
; 		return;
; 	}

; 	php_gtk_object_init(wrapped_obj, this_ptr);
; }
; %% }}}


;;; another constructor, which was overridden anyway
; %% {{{ GtkCheckMenuItem

; %%

; %%
; override gtk_check_menu_item_new
; PHP_FUNCTION(gtk_check_menu_item_new)
; {
; 	char *label;
; 	GtkObject *wrapped_obj;
; #ifdef PHP_WIN32
; 	gchar *utf8_label = NULL;
; #endif
	
; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "|s", &label)) {
; 		php_gtk_invalidate(this_ptr);
; 		return;
; 	}

; 	if (label) {
; #ifdef PHP_WIN32
; 		utf8_label = g_convert(label, strlen(label), "UTF-8", GTK_G(codepage), NULL, NULL, NULL);
; 		wrapped_obj = (GtkObject *)gtk_check_menu_item_new_with_label(utf8_label);
; 		if (utf8_label) g_free(utf8_label);
; #else
; 		wrapped_obj = (GtkObject *)gtk_check_menu_item_new_with_label(label);		
; #endif
; 	}
; 	else
; 	    wrapped_obj = (GtkObject *)gtk_check_menu_item_new();

; 	if (!wrapped_obj) {
; 		php_error(E_WARNING, "%s(): could not create GtkCheckMenuItem object",
; 				  get_active_function_name(TSRMLS_C));
; 		php_gtk_invalidate(this_ptr);
; 		return;
; 	}

; 	php_gtk_object_init(wrapped_obj, this_ptr);
; }

; %% }}}



;;; I think that this one should work out okay wihout being overridden.
; %%
; overrides gtk_rc_get_default_files
; PHP_FUNCTION(gtk_rc_get_default_files)
; {
; 	gchar **ret;
	
; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), ""))
; 		return;

; 	ret = gtk_rc_get_default_files();
; 	if (ret) {
; 		array_init(return_value);
; 		while (*ret) {
; 			add_next_index_string(return_value, *ret, 1);
; 			*ret++;
; 		}
; 		g_free(ret);
; 	} else
; 		RETURN_NULL();
; }
; %% }}}


;;;; constructor... already overridden
; %% {{{ GtkCList

; %%

; %%
; override gtk_clist_new
; PHP_FUNCTION(gtk_clist_new)
; {
; 	GtkObject *wrapped_obj;
; 	gint columns, i;
; 	gchar **titles;
; #ifdef PHP_WIN32
; 	gchar *utf8_title = NULL;
; #endif
; 	zval *php_titles = NULL, **temp_title;
; 	HashTable *target_hash;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "i|a/", &columns, &php_titles)) {
; 		php_gtk_invalidate(this_ptr);
; 		return;
; 	}

; 	if (columns <= 0) {
; 		php_error(E_WARNING, "%s() needs number of columns to be > 0", get_active_function_name(TSRMLS_C));
; 		php_gtk_invalidate(this_ptr);
; 		return;
; 	}

; 	if (php_titles) {
; 		if (zend_hash_num_elements(Z_ARRVAL_P(php_titles)) < columns) {
; 			php_error(E_WARNING, "%s(): the array of titles is not long enough", get_active_function_name(TSRMLS_C));
; 			php_gtk_invalidate(this_ptr);
; 			return;
; 		}

; 		target_hash = HASH_OF(php_titles);
; 		titles = emalloc(sizeof(gchar *) * columns);
; 		i = 0;
; 		zend_hash_internal_pointer_reset(target_hash);
; 		while (zend_hash_get_current_data(target_hash, (void **)&temp_title) == SUCCESS) {
; 			convert_to_string_ex(temp_title);

; #ifdef PHP_WIN32
; 			utf8_title = g_convert(Z_STRVAL_PP(temp_title), Z_STRLEN_PP(temp_title), "UTF-8", GTK_G(codepage), NULL, NULL, NULL);
; 			titles[i++] = utf8_title;
; #else
; 			titles[i++] = estrndup(Z_STRVAL_PP(temp_title), Z_STRLEN_PP(temp_title));
; #endif

; 			zend_hash_move_forward(target_hash);
; 		}
; 		wrapped_obj = (GtkObject *)gtk_clist_new_with_titles(columns, titles);
; 		efree(titles);
; 	} else
; 		wrapped_obj = (GtkObject *)gtk_clist_new(columns);

; 	if (!wrapped_obj) {
; 		php_error(E_WARNING, "%s(): could not create GtkCList object", get_active_function_name(TSRMLS_C));
; 		php_gtk_invalidate(this_ptr);
; 		return;
; 	}

; 	php_gtk_object_init(wrapped_obj, this_ptr);	
; }



(defmethod GtkCList (append text)
   (set! text (maybe-unbox text))
   (let (($this::GtkCList*
	  (if (php-null? (maybe-unbox $this))
              (pragma::GtkCList* "NULL")
              (GTK_CLIST
	       (gtk-object/safe 'GtkCList $this return)))))
      (unless (= (php-hash-size text) (GtkCList*-columns $this))
	 (php-warning "the array of strings (" (php-hash-size text)
		      ") does not match the number of colums (" (GtkCList*-columns $this) ")")
	 (return NULL))
      (let ((strings::string*
	     (string-list->string* (map convert-to-utf8 (php-hash->list text)))))
	 (convert-to-integer (pragma::int
			      "gtk_clist_append($1, $2)"
			      $this
			      strings)))))

;; same as above except it calls prepend
(defmethod GtkCList (prepend text)
   (set! text (maybe-unbox text))
   (let (($this::GtkCList*
	  (if (php-null? (maybe-unbox $this))
              (pragma::GtkCList* "NULL")
              (GTK_CLIST
	       (gtk-object/safe 'GtkCList $this return)))))
      (unless (= (php-hash-size text) (GtkCList*-columns $this))
	 (php-warning "the array of strings (" (php-hash-size text)
		      ") does not match the number of colums (" (GtkCList*-columns $this) ")")
	 (return NULL))
      (let ((strings::string*
	     (string-list->string* (map convert-to-utf8 (php-hash->list text)))))
	 (convert-to-integer (pragma::int
			      "gtk_clist_prepend($1, $2)"
			      $this
			      strings)))))
      
      
;; again, the same afaict
(defmethod GtkCList (insert row text)
   (set! text (maybe-unbox text))
   (let (($this::GtkCList*
	  (if (php-null? (maybe-unbox $this))
              (pragma::GtkCList* "NULL")
              (GTK_CLIST
	       (gtk-object/safe 'GtkCList $this return)))))
      (unless (= (php-hash-size text) (GtkCList*-columns $this))
	 (php-warning "the array of strings (" (php-hash-size text)
		      ") does not match the number of colums (" (GtkCList*-columns $this) ")")
	 (return NULL))
      (let ((strings::string*
	     (string-list->string* (map convert-to-utf8 (php-hash->list text)))))
	 (convert-to-integer (pragma::int
			      "gtk_clist_insert($1, $2, $3)"
			      $this
			      (mkfixnum row)
			      strings)))))


(defmethod GtkCList (get_text row column)
   (set! row (mkfixnum row))
   (set! column (mkfixnum column))
   (let (($this::GtkCList*
	  (if (php-null? (maybe-unbox $this))
              (pragma::GtkCList* "NULL")
              (GTK_CLIST
	       (gtk-object/safe 'GtkCList $this return)))))
      (let ((text::string (pragma::string "NULL")))
	 (when (zero? (gtk_clist_get_text $this row column (pragma::gchar** "&$1" text)))
	    (php-warning "cannot get text value")
	    (return NULL))
	 (if (pragma::bool "($1 != NULL)" text)
	     (convert-to-codepage text)
	     NULL))))
	 


; override gtk_clist_get_pixmap
; PHP_FUNCTION(gtk_clist_get_pixmap)
; {
; 	zval *php_pixmap = NULL, *php_mask = NULL;
; 	int column, row;
; 	GdkPixmap *pixmap = NULL;
; 	GdkBitmap *mask = NULL;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "ii", &row, &column))
; 		return;

; 	if (!gtk_clist_get_pixmap(GTK_CLIST(PHP_GTK_GET(this_ptr)), row, column,
; 							  &pixmap, &mask)) {
; 		php_error(E_WARNING, "%s() cannot get pixmap value", get_active_function_name(TSRMLS_C));
; 		return;
; 	}

; 	php_pixmap = php_gdk_pixmap_new(pixmap);
; 	php_mask = php_gdk_bitmap_new(mask);

; 	*return_value = *php_gtk_build_value("(NN)", php_pixmap, php_mask);
; }
; %%



; %%
; override gtk_ctree_node_set_row_data
; PHP_FUNCTION(gtk_ctree_node_set_row_data)
; {
; 	zval *node, *data;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "OV", &node, gtk_ctree_node_ce, &data))
; 		return;

; 	zval_add_ref(&data);
; 	gtk_ctree_node_set_row_data_full(GTK_CTREE(PHP_GTK_GET(this_ptr)),
; 									 PHP_GTK_CTREE_NODE_GET(node), data,
; 									 php_gtk_destroy_notify);
; }
; %%

; override gtk_clist_set_row_data
; PHP_FUNCTION(gtk_clist_set_row_data)
; {
; 	zval *data;
; 	int row;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "iV", &row, &data))
; 		return;

; 	zval_add_ref(&data);
; 	gtk_clist_set_row_data_full(GTK_CLIST(PHP_GTK_GET(this_ptr)), row, data,
; 								php_gtk_destroy_notify);
; }
; %%


; override gtk_clist_get_pixtext
; PHP_FUNCTION(gtk_clist_get_pixtext)
; {
; 	zval *php_pixmap = NULL, *php_mask = NULL;
; 	int column, row;
; 	gchar *text = NULL;
; 	guint8 spacing;
; 	GdkPixmap *pixmap = NULL;
; 	GdkBitmap *mask = NULL;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "ii", &row, &column))
; 		return;

; 	if (!gtk_clist_get_pixtext(GTK_CLIST(PHP_GTK_GET(this_ptr)),
; 							   row, column, &text, &spacing, &pixmap, &mask)) {
; 		php_error(E_WARNING, "%s() cannot get pixtext value", get_active_function_name(TSRMLS_C));
; 		return;
; 	}

; 	php_pixmap = php_gdk_pixmap_new(pixmap);
; 	php_mask = php_gdk_bitmap_new(mask);

; 	*return_value = *php_gtk_build_value("(siNN)", text, (int)spacing,
; 										 php_pixmap, php_mask);
; }
; %%


; %% {{{ GtkColorSelection
; %%
; override gtk_color_selection_set_color
; PHP_FUNCTION(gtk_color_selection_set_color)
; {
; 	gdouble value[4];

; 	NOT_STATIC_METHOD();

; 	value[3] = 1.0;
; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "ddd|d",
; 							&value[0], &value[1], &value[2], &value[3]))
; 		return;

; 	gtk_color_selection_set_color(GTK_COLOR_SELECTION(PHP_GTK_GET(this_ptr)), value);
; }
; %%



; override gtk_color_selection_get_color
; PHP_FUNCTION(gtk_color_selection_get_color)
; {
; 	gdouble value[4];
; 	GtkColorSelection *colorsel;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), ""))
; 		return;

; 	colorsel = GTK_COLOR_SELECTION(PHP_GTK_GET(this_ptr));
; 	gtk_color_selection_get_color(colorsel, value);
; 	if (colorsel->use_opacity)
; 		*return_value = *php_gtk_build_value("(dddd)", value[0], value[1], value[2], value[3]);
; 	else
; 		*return_value = *php_gtk_build_value("(ddd)", value[0], value[1], value[2]);
; }
; %% }}}



; %% {{{ GtkCombo
; %%
; override gtk_combo_set_popdown_strings
; PHP_FUNCTION(gtk_combo_set_popdown_strings)
; {
; 	zval *php_list, **item;
; 	GList *list = NULL;
; #ifdef PHP_WIN32
; 	gchar *utf8_text = NULL;
; #endif

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "a/", &php_list))
; 		return;

; 	zend_hash_internal_pointer_reset(Z_ARRVAL_P(php_list));
; 	while (zend_hash_get_current_data(Z_ARRVAL_P(php_list), (void **)&item) == SUCCESS) {
; 		convert_to_string_ex(item);
; #ifdef PHP_WIN32
; 		utf8_text = g_convert(Z_STRVAL_PP(item), Z_STRLEN_PP(item), "UTF-8", GTK_G(codepage), NULL, NULL, NULL);
; 		list = g_list_append(list, utf8_text);
; #else
; 		list = g_list_append(list, Z_STRVAL_PP(item));
; #endif
; 		zend_hash_move_forward(Z_ARRVAL_P(php_list));
; 	}

; 	gtk_combo_set_popdown_strings(GTK_COMBO(PHP_GTK_GET(this_ptr)), list);
; 	g_list_free(list);
; 	RETURN_TRUE;
; }
; %% }}}


; %% {{{ GtkContainer
; %%
; override gtk_container_children
; PHP_FUNCTION(gtk_container_children)
; {
; 	GList *children, *tmp;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), ""))
; 		return;

; 	children = gtk_container_children(GTK_CONTAINER(PHP_GTK_GET(this_ptr)));
; 	array_init(return_value);
; 	for (tmp = children; tmp; tmp = tmp->next)
; 		add_next_index_zval(return_value, php_gtk_new(tmp->data));
; 	g_list_free(children);
; }
; %% }}}



; %%
; override gtk_clist_append
; PHP_FUNCTION(gtk_clist_append)
; {
; 	gint columns, i;
; 	gchar **list;
; #ifdef PHP_WIN32
; 	gchar *utf8_text = NULL;
; #endif
; 	zval *php_list, **text;
; 	HashTable *target_hash;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "a/", &php_list)) {
; 		php_gtk_invalidate(this_ptr);
; 		return;
; 	}

; 	columns = GTK_CLIST(PHP_GTK_GET(this_ptr))->columns;
; 	if (zend_hash_num_elements(Z_ARRVAL_P(php_list)) != columns) {
; 		php_error(E_WARNING, "%s(): the array of strings (%d) does not match the number of columns (%d)",
; 				  get_active_function_name(TSRMLS_C), zend_hash_num_elements(Z_ARRVAL_P(php_list)), columns);
; 		return;
; 	}
	
; 	target_hash = HASH_OF(php_list);
; 	list = emalloc(sizeof(gchar *) * columns);
; 	i = 0;
; 	zend_hash_internal_pointer_reset(target_hash);
; 	while (zend_hash_get_current_data(target_hash, (void **)&text) == SUCCESS) {
; 		convert_to_string_ex(text);

; #ifdef PHP_WIN32
; 		utf8_text = g_convert(Z_STRVAL_PP(text), Z_STRLEN_PP(text), "UTF-8", GTK_G(codepage), NULL, NULL, NULL);
; 		list[i++] = utf8_text;
; #else
; 		list[i++] = estrndup(Z_STRVAL_PP(text), Z_STRLEN_PP(text));
; #endif

; 		zend_hash_move_forward(target_hash);
; 	}
; 	ZVAL_LONG(return_value, gtk_clist_append(GTK_CLIST(PHP_GTK_GET(this_ptr)), list));
; 	efree(list);
; }


; %%
; override gtk_clist_prepend
; PHP_FUNCTION(gtk_clist_prepend)
; {
; 	gint columns, i;
; 	gchar **list;
; #ifdef PHP_WIN32
; 	gchar *utf8_text = NULL;
; #endif
; 	zval *php_list, **text;
; 	HashTable *target_hash;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "a/", &php_list)) {
; 		php_gtk_invalidate(this_ptr);
; 		return;
; 	}

; 	columns = GTK_CLIST(PHP_GTK_GET(this_ptr))->columns;
; 	if (zend_hash_num_elements(Z_ARRVAL_P(php_list)) < columns) {
; 		php_error(E_WARNING, "%s(): the array of strings is not long enough", get_active_function_name(TSRMLS_C));
; 		return;
; 	}

; 	target_hash = HASH_OF(php_list);
; 	list = emalloc(sizeof(gchar *) * columns);
; 	i = 0;
; 	zend_hash_internal_pointer_reset(target_hash);
; 	while (zend_hash_get_current_data(target_hash, (void **)&text) == SUCCESS) {
; 		convert_to_string_ex(text);

; #ifdef PHP_WIN32
; 		utf8_text = g_convert(Z_STRVAL_PP(text), Z_STRLEN_PP(text), "UTF-8", GTK_G(codepage), NULL, NULL, NULL);
; 		list[i++] = utf8_text;
; #else
; 		list[i++] = estrndup(Z_STRVAL_PP(text), Z_STRLEN_PP(text));
; #endif

; 		zend_hash_move_forward(target_hash);
; 	}
; 	ZVAL_LONG(return_value, gtk_clist_prepend(GTK_CLIST(PHP_GTK_GET(this_ptr)), list));
; 	efree(list);
; }


; override gtk_clist_insert
; PHP_FUNCTION(gtk_clist_insert)
; {
; 	gint columns, i, row;
; 	gchar **list;
; #ifdef PHP_WIN32
; 	gchar *utf8_text = NULL;
; #endif
; 	zval *php_list, **text;
; 	HashTable *target_hash;

; 	NOT_STATIC_METHOD();

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "ia/", &row, &php_list)) {
; 		php_gtk_invalidate(this_ptr);
; 		return;
; 	}

; 	columns = GTK_CLIST(PHP_GTK_GET(this_ptr))->columns;
; 	if (zend_hash_num_elements(Z_ARRVAL_P(php_list)) < columns) {
; 		php_error(E_WARNING, "%s(): the array of strings is not long enough", get_active_function_name(TSRMLS_C));
; 		return;
; 	}

; 	target_hash = HASH_OF(php_list);
; 	list = emalloc(sizeof(gchar *) * columns);
; 	i = 0;
; 	zend_hash_internal_pointer_reset(target_hash);
; 	while (zend_hash_get_current_data(target_hash, (void **)&text) == SUCCESS) {
; 		convert_to_string_ex(text);

; #ifdef PHP_WIN32
; 		utf8_text = g_convert(Z_STRVAL_PP(text), Z_STRLEN_PP(text), "UTF-8", GTK_G(codepage), NULL, NULL, NULL);
; 		list[i++] = utf8_text;
; #else
; 		list[i++] = estrndup(Z_STRVAL_PP(text), Z_STRLEN_PP(text));
; #endif

; 		zend_hash_move_forward(target_hash);
; 	}
; 	ZVAL_LONG(return_value, gtk_clist_insert(GTK_CLIST(PHP_GTK_GET(this_ptr)), row, list));
; 	efree(list);
; }
; %%



      

; override gtk_clist_get_text
; PHP_FUNCTION(gtk_clist_get_text)
; {
; 	gint row, column;
; 	gchar *text = NULL;
; #ifdef PHP_WIN32
; 	gchar *cp_text = NULL;
; #endif

; 	if (!php_gtk_parse_args(ZEND_NUM_ARGS(), "ii", &row, &column))
; 		return;

; 	if (!gtk_clist_get_text(GTK_CLIST(PHP_GTK_GET(this_ptr)), row, column, &text)) {
; 		php_error(E_WARNING, "%s() cannot get text value", get_active_function_name(TSRMLS_C));
; 		return;
; 	}

; #ifdef PHP_WIN32
; 	if (text) {
; 		cp_text = g_convert(text, strlen(text), GTK_G(codepage), "UTF-8", NULL, NULL, NULL);
; 		RETURN_STRING(cp_text, 1);
; 		g_free(cp_text);
; 	}
; 	else {
; 		RETURN_NULL();
; 	}
; #else
; 	RETURN_STRING(text, 1);
; #endif
; }
; %%