#!/usr/bin/perl

#    Copyright 2004 Corey Goldberg (corey@test-tools.net)
#
#    This file is part of WebInject.
#
#    WebInject is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    WebInject is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with WebInject; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


use Tk;
use Tk::Stderr;
use Tk::ROText;
use Tk::Compound;
use Tk::ProgressBar::Mac;
use Tk::CollapsableFrame;
use Tk::LabEntry;





$| = 1; #don't buffer output


 
$mw = MainWindow->new(-title            => 'WebInject - HTTP Test Tool    (version 2.0 alpha)',
                      -bg               => '#666699',
                      -takefocus        => '1'  #start on top
                      );
$mw->geometry("650x650+0+0");  #size and screen placement
$mw->InitStderr; #redirect all STDERR to a window
$mw->raise; #put application in front at startup
$mw->bind('<F5>' => \&engine);  #F5 key makes it run


if (-e "logo.gif") {  #if icon graphic exists, use it
    $mw->update();
    $icon = $mw->Photo(-file => 'icon.gif');
    $mw->iconimage($icon);
}


if (-e "logo.gif") {  #if logo graphic exists, use it
    $mw->Photo('logogif', -file => "logo.gif");    
    $mw->Label(-image => 'logogif', 
                -bg    => '#666699'
                )->place(qw/-x 255 -y 12/); $mw->update();
}


$mw->Label(-text  => 'Engine Status:',
            -bg    => '#666699'
            )->place(qw/-x 25 -y 110/); $mw->update();


$out_window = $mw->Scrolled(ROText,  #engine status window 
                   -scrollbars  => 'e',
                   -background  => '#EFEFEF',
                   -relief      => 'ridge',
                   -width       => '85',
                   -height      => '7'
                  )->place(qw/-x 25 -y 128/); $mw->update();


$mw->Label(-text  => 'Test Case Status:',
           -bg    => '#666699'
           )->place(qw/-x 25 -y 238/); $mw->update(); 


$status_window = $mw->Scrolled(ROText,  #test case status window 
                   -scrollbars  => 'e',
                   -background  => '#EFEFEF',
                   -relief      => 'ridge',
                   -width       => '85',
                   -height      => '19'
                  )->place(qw/-x 25 -y 256/); $mw->update();
$status_window->tagConfigure('red', -foreground => '#FF3333');  #define tag for font color
$status_window->tagConfigure('green', -foreground => '#009900'); #define tag for font color








$colf_canvas = $mw->Canvas(-height              => '100', 
                           -width               => '600',
                           -background          => '#666699',
                           -highlightthickness  => '0'
                          )->place(qw/-x 25 -y 540/); $mw->update();
                          
$collapse_frame = $colf_canvas->CollapsableFrame(-title         => 'Load Test Options:',
                                                 -height        => '100',
                                                 -width         => '600',
                                                 -background    => '#666699'
                                                )->place(qw/-x 0 -y 0/); $mw->update();
$collapse_frame->{frame}->configure(-background => '#EFEFEF');
$collapse_frame->{ident}->configure(-background => '#EFEFEF');
$collapse_frame->{opcl}->configure(-background  => '#EFEFEF');
$colf = $collapse_frame->Subwidget();  #put stuff in colf to get it inside the collapsableframe
$colf->configure(-background => '#EFEFEF');

#$mw->Label(-text  => 'Load Test Options:',
#           -bg    => '#EFEFEF'
#           )->place(qw/-x 51 -y 543/); $mw->update(); 

#$mw->Canvas(-height             => '24', 
#            -width              => '485',
#            -background         => '#666699',
#            -highlightthickness => '0'
#           )->place(qw/-x 142 -y 540/); $mw->update();

if ($^O eq 'MSWin32') {  #check to see if they are running Windows OS  
    $colf->Label(-text          => 'Sorry, You are running MS Windows.  WebInject only supports multiprocessed load testing on Unix/Linux.',
                 -background    => '#EFEFEF'
                )->pack(-anchor => 'w', -pady => '20'); $mw->update();
}
else {  #if they are not on windows, give the load testing options
    $colf->LabEntry(-label        => 'Number of Processes',
                    -background   => '#EFEFEF',
                    -textvariable => \$numprocs
                   )->pack(-anchor => 'w', -pady => '20'); $mw->update();
}
 










$rtc_button = $mw->Button->Compound;
$rtc_button->Text(-text => "Run Test Cases");
$rtc_button = $mw->Button(-width              => '100',
                          -height             => '13',
                          -background         => '#EFEFEF',
                          -activebackground   => '#666699',
                          -foreground         => '#000000',
                          -activeforeground   => '#FFFFFF',
                          -borderwidth        => '3',
                          -image              => $rtc_button,
                          -command            => sub{engine();}
                          )->place(qw/-x 25 -y 75/); $mw->update();
$rtc_button->focus();


$restart_button = $mw->Button->Compound;
$restart_button->Text(-text => "Restart");
$restart_button = $mw->Button(-width          => '50',
                          -height             => '13',
                          -background         => '#EFEFEF',
                          -activebackground   => '#666699',
                          -foreground         => '#000000',
                          -activeforeground   => '#FFFFFF',
                          -borderwidth        => '3',
                          -image              => $restart_button,
                          -command            => sub{gui_restart();}
                          )->place(qw/-x 5 -y 5/); $mw->update();


$exit_button = $mw->Button->Compound;
$exit_button->Text(-text => "Exit");
$exit_button = $mw->Button(-width              => '40',
                           -height             => '13',
                           -background         => '#EFEFEF',
                           -activebackground   => '#666699',
                           -foreground         => '#000000',
                           -activeforeground   => '#FFFFFF',
                           -borderwidth        => '3',
                           -image              => $exit_button,
                           -command            => sub{exit;}
                           )->place(qw/-x 596 -y 5/); $mw->update();


$progressbar = $mw->ProgressBar(-width  => '420', 
                                -bg     => '#666699'
                                )->place(qw/-x 146 -y 75/); $mw->update();


$status_ind = $mw->Canvas(-width       => '28',  #engine status indicator 
                          -height      => '9',                   
                          -background  => '#666699',
                          )->place(qw/-x 591 -y 79/); $mw->update(); 




#load the Engine
if (-e "./webinject.pl") {
    do "./webinject.pl"   
} 
#test if the Engine was loaded
unless (defined &engine){
        print STDERR "Error: I can not load the test engine (webinject.pl)!\n\n";
        print STDERR "Check to make sure webinject.pl exists.\n";
        print STDERR "If it is not missing, you are most likely missing some Perl modules it requires.\n";
        print STDERR "Try running the engine by itself and see what modules it complains about.\n\n";
}




MainLoop;




#------------------------------------------------------------------
sub gui_initial {   #this runs when engine is first loaded
    
    #vars set in test engine
    $currentcasefile = ''; 
    $testnum = ''; 
    $casecount = '';
    $description1 = '';
    $totalruncount = '';
    $failedcount = '';
    $passedcount = '';
    $casefailedcount = '';
    $casepassedcount = '';
    $totalruntime = '';
    $numprocs = 1;
    @monitor = ();

    $out_window->delete('0.0','end');  #clear window before starting
    
    $status_window->delete('0.0','end');  #clear window before starting
    
    $status_ind->configure(-background  => '#FF9900');  #change status color amber while running

    $rtc_button->configure(-state       => 'disabled',  #disable button while running
                           -background  => '#666699',
                           );
    
    $out_window->insert("end", "Starting Webinject Engine... \n\n"); $out_window->see("end");
}
#------------------------------------------------------------------
sub gui_restart {
    exec 'perl ./webinjectgui.pl';  # kill the entire app and restart it
}
#------------------------------------------------------------------
sub gui_processing_msg {
    $out_window->insert("end", "processing test case file:\n$currentcasefile\n\n", 'bold'); $out_window->see("end");
}
#------------------------------------------------------------------
sub gui_statusbar {
    $percentcomplete = ($testnum/$casecount)*100;  
    $progressbar->set($percentcomplete);  #update progressbar with current status
}
#------------------------------------------------------------------
sub gui_tc_descript {
    $status_window->insert("end", "- $description1\n"); $status_window->see("end");
}
#------------------------------------------------------------------
sub gui_status_passed {
    $status_window->insert("end", "PASSED\n", 'green'); $status_window->see("end");
} 
#------------------------------------------------------------------
sub gui_status_failed {
    if ($1 and $2) {
        $status_window->insert("end", "FAILED ($1$2)\n", 'red'); $status_window->see("end");
    } 
    else {
        $status_window->insert("end", "FAILED\n", 'red'); $status_window->see("end");
    }
}
#------------------------------------------------------------------
sub gui_final {
    $out_window->insert("end", "Execution Finished... see results.html file for detailed output"); $out_window->see("end");
    
    $status_window->insert("end", "\n\n------------------------------\nTotal Run Time: $totalruntime  seconds\n");
    $status_window->insert("end", "\nTest Cases Run: $totalruncount\nTest Cases Passed: $casepassedcount\nTest Cases Failed: $casefailedcount\nVerifications Passed: $passedcount\nVerifications Failed: $failedcount\n"); 
    $status_window->see("end");

    if ($failedcount > 0) {  #change status color to reflect failure or all tests passed
            $status_ind->configure(-background  => '#FF3333');  #red
    } 
    else {
            $status_ind->configure(-background  => '#009900');  #green
    }
     
     
    $rtc_button->configure(-state       => 'normal',  #re-enable button after finish
                           -background  => '#EFEFEF',
                           );
}
#------------------------------------------------------------------
sub monitor_window {
    $mondisplay = " \n";
    $status_window->delete('0.0','end');  #clear window before updating
    
    foreach (@monitor) {  #process each line of the array into a scalar text var for display
	$mondisplay = "$mondisplay" . "$_";	
    }
    
    $status_window->insert("end",  $mondisplay);
    $status_window->update();
}
#------------------------------------------------------------------
