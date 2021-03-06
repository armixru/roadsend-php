<?php
/* $Id: scribble.php,v 1.2 2005/06/02 15:45:46 tim Exp $ */

if (!extension_loaded('gtk')) {
	dl( 'php_gtk.' . PHP_SHLIB_SUFFIX);
}

$pixmap = null;

function configure_event($widget, $event)
{
	global	$pixmap;

	$pixmap = new GdkPixmap($widget->window,
				$widget->allocation->width,
				$widget->allocation->height,
				-1);
        
        $clTransparentTest =& new GdkColor(0, 0, 0);
        gdk::gdk_color_parse('#FFAA33', $clTransparentTest);
        $style =& new GtkStyle();
        $style->base[GTK_STATE_NORMAL] = $clTransparentTest;
        

	gdk::draw_rectangle($pixmap,
                            $widget->style->white_gc,
                            // xxx this is where I was working on the
                            //gdk_color_parse test.  I haven't
                            //finished it yet. --timjr.
                            // $style,
			    true, 0, 0,
			    $widget->allocation->width,
			    $widget->allocation->height);

	return true;
}


function expose_event($widget, $event)
{
	global	$pixmap;

	gdk::draw_pixmap($widget->window,
			 $widget->style->fg_gc[$widget->state],
			 $pixmap,
			 $event->area->x, $event->area->y,
			 $event->area->x, $event->area->y,
			 $event->area->width, $event->area->height);

	return false;
}


function button_press_event($widget, $event)
{
	global	$pixmap;

	if ($event->button == 1 && $pixmap)
		draw_brush($widget, (int)$event->x, (int)$event->y);

	return true;
}


function motion_notify_event($widget, $event)
{
	global	$pixmap;

	if ($event->is_hint) {
		$window = $event->window;
		$pointer = $window->get_pointer();
		$x = (int)$pointer[0];
		$y = (int)$pointer[1];
		$state = $pointer[2];
	} else {
		$x = (int)$event->x;
		$y = (int)$event->y;
		$state = $event->state;
	}

	if (($state & GDK_BUTTON1_MASK) && $pixmap)
		draw_brush($widget, $x, $y);

	return true;
}


function draw_brush($widget, $x, $y)
{
	global	$pixmap;

	gdk::draw_arc($pixmap, $widget->style->black_gc,
				  true, $x - 4, $y - 4, 8, 8, 0, 64 * 360); 
	$widget->draw(new GdkRectangle($x - 4, $y - 4, 8, 8));
}


$window = &new GtkWindow();
$window->set_name('Test Input');
$window->set_position(GTK_WIN_POS_CENTER);

$window->connect_object('destroy', array('gtk', 'main_quit'));

$vbox = &new GtkVBox();
$window->add($vbox);
$vbox->show();

$drawing_area = &new GtkDrawingArea();
$drawing_area->size(300, 300);
$vbox->pack_start($drawing_area);
$drawing_area->show();

$drawing_area->connect('expose_event', 'expose_event');
$drawing_area->connect('configure_event', 'configure_event');

$drawing_area->connect('motion_notify_event', 'motion_notify_event');
$drawing_area->connect('button_press_event', 'button_press_event');

$drawing_area->set_events(GDK_EXPOSURE_MASK
			  | GDK_LEAVE_NOTIFY_MASK
			  | GDK_BUTTON_PRESS_MASK
			  | GDK_POINTER_MOTION_MASK
			  | GDK_POINTER_MOTION_HINT_MASK);

$button = &new GtkButton('Quit');
$vbox->pack_start($button, false, false);
$button->connect_object('clicked', array($window, 'destroy'));
$button->show();

$window->show();

gtk::main();

?>
