<?php
   $domain=ereg_replace('[^\.]*\.(.*)$','\1',$_SERVER['HTTP_HOST']);
   $group_name=ereg_replace('([^\.]*)\..*$','\1',$_SERVER['HTTP_HOST']); 
   $themeroot='http://r-forge.r-project.org/themes/rforge/';
   echo '<?xml version="1.0" encoding="UTF-8"?>';
   ?>
<!DOCTYPE html
	  PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
	  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> 
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en"> 
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/> 
    <title>The POT Package: An R package to model peaks over threshold</title>
    <link rel="stylesheet" media="screen" type="text/css"
	  title="My Design" href="css/mystyle.css" />
    <link rel="icon" type="image/png" 
	  href="http://developer.r-project.org/Logo/Rlogo-5.png" />
  </head>
  <body>
    <div id="wrapper">
      <!-- header part -->
      <div id="header">
	<span id="Rlogo">
	  provided by
	  <a href="/">
	    <img src="<?php echo $themeroot; ?>/images/logo.png"
		 width="100%" align="left" alt="RForge Logo" />	    
	  </a>   
	</span>   
	<div class="mainTitle">The POT Package:<br/> An R Package to Model Peaks Over a
	Threshold</div>
      </div>
      <!-- menu part -->  
      <div id="left">
	<?php include "phpPages/menu.php"; ?>
      </div>
      <!-- main matter part -->
      <div id="main_matter">  
	<?php include "phpPages/welcome.php"; ?>
	<h2 id="features">Features</h2>
	<?php include "phpPages/features.php"; ?>
	<h2 id="screen_shots">Screen Shots</h2>
	<?php include "phpPages/screen_shots.php"; ?>
	<h2 id="pot_few_lines">The POT Package in a Few Lines</h2>
	<?php include "phpPages/pot_few_lines.php"; ?>
	<h2 id="manuals">Manuals</h2> 
	<?php include "phpPages/manuals.php"; ?>
	<h2 id="contact">Contact</h2> Any suggestions, feature requests,
	bugs: <a href="http://r-forge.r-project.org/tracker/?group_id=76">
	  select the appropriate tracker</a><br/> Author: Mathieu
	Ribatet <a href="http://www.lyon.cemagref.fr/hh/hydrologie/scientifiques/ribatet/hydrology-english.shtml">
	  (homepage)</a>
      </div>
      <!-- footnote part -->
      <div id="footnote">
	<p>$LastChangedDate: 2007-11-07 11:56:13 +0100 (mer, 07 nov
	2007) $</p>
	<p>
	  <a href="http://validator.w3.org/check?uri=referer">
	    <img src="http://www.w3.org/Icons/valid-xhtml10-blue"
		 alt="Valid XHTML 1.0 Transitional" height="31"
		 width="88" />
	  </a>
	  <a href="http://validator.w3.org/check?uri=referer">
	    <img src="http://www.w3.org/Icons/valid-css"
		 alt="Valid CSS" height="31"
		 width="88" />
	  </a>
	</p>
      </div>
    </div>
  </body>
</html>
