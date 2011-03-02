*******************************************************************
 Antenna House's differential file kit for DITA Open Toolkit 1.4
*******************************************************************

This archive contains differential ant build files and XSL stylesheets for XSL Formatter users who want to use it in DITA Open Toolkit 1.4.

File lists
==========

[root]
 |
 +-- readme_axf.txt (this file)
 |   APACHE-LICENSE-2_0.html
 |
 +-- axfo_setting.xml
 |
 +-- build_dita2pdf.xml
 |
 +--[xsl]
 |    |
 |    +-- dita2fo-shell_axf.xsl
 |    |
 |    +--[xslfo]
 |         |
 |         +-- dita2fo-index_axf.xsl
 +--[demo]
      |
      +--[fo]
           | 
           +-- build.xml
           |
           +--[xsl]
           |    |
           |    +--[fo]
           |         |
           |         +-- topic2fo_shell_1.0_axf.xsl
           |             topic2fo_shell_axf.xsl
           |             index_axf.xsl
           |             fix_uri_axf.xsl
           |
           +--[cfg]
                |
                +-- catalog.xml
                |
                +--[fo]
                     |
                     +-- layout-masters_axf.xml
                     |
                     +--[attrs]
                          |
                          +-- index-attr_axf.xsl
                              tables-attr_axf.xsl
                              toc-attr_axf.xsl


How to install?
===============

[DITA Open Toolkit 1.4]

If you are not installed DITA Open Toolkit 1.4 yet, download and install it. The detailed installation document is placed in doc/installguide/index.html. To use XSL Formatter instead of FOP as XSL-FO processor, follow the next steps.

1. Make backup of the build_dita2pdf.xml, then replace it by attached build_dita2pdf.xml. By changing this file, ant invokes XSL Formatter instead of FOP.

2. Copy the attached xsl/dita2fo-shell_axf.xsl to the xsl directory. Also copy the attached xsl/xslfo/dita2fo-index_axf.xsl file to the xsl/xslfo directory. These stylesheets contain some XSL Formatter specialized features and bug fixes, simple index generation.

3. Set environment variable AXF_DIR to the XSL Formatter installation directory. If you are using Windows, for example:

 set AXF_DIR=C:\Program FIles\Antenna\XSLFormatterV4

If you are using Linux, for example:
 
 export AXF_DIR=/usr/XSLFormatterV4

4. If you want to use option file for XSL formatter, set AXF_OPT environment variable to specify the file. If you are using Windows, for example:

 set AXF_OPT=C:\axfo_setting.xml

If you are using Linux, for example:

 set AXF_OPT=/home/axf/axfo_setting.xml

Attached axfo_setting.xml is a sample for DITA Open Toolkit specialized setting.

5. Move the current directory to the Open Toolkit home directory. Invoke ant from command-line specifying target like following.

 ant -f build_demo.xml demo.book

[Idiom's FO output plug-in]

If you are using Idiom's FO output plug-in, you can use XSL Formatter instead of XEP. Follow the next steps.

1. Make backup of /demo/fo/build.xml, then replace it attached demo/fo/build.xml. Attached build.xml enables you to invoke XSL Formatter instead of XEP.

2. Copy the the following file to the corresponding demo/fo/xsl/fo directory.
 demo/fo/xsl/fo/topic2fo_shell_1.0_axf.xsl
 demo/fo/xsl/fo/topic2fo_shell_axf.xsl
 demo/fo/xsl/fo/index_axf.xsl
 demo/fo/xsl/fo/fix_uri_axf.xsl
 
3. Make backup of /demo/fo/cfg/catalog.xml, then replace it attached demo/fo/cfg/catalog.xml. 

4. Copy the following file to the corresponding demo/fo/cfg/fo directory.
 demo/fo/cfg/fo/layout-masters_axf.xml

5. Copy the following file to the corresponding demo/fo/cfg/fo/attrs directory.
 demo/fo/cfg/fo/attrs/index-attr_axf.xsl
 demo/fo/cfg/fo/attrs/tables-attr_axf.xsl
 demo/fo/cfg/fo/attrs/toc-attr_axf.xsl

6. Set environment variables AXF_DIR, AXF_OPT according to the previous section's example.

7. Move the current directory to the Open Toolkit home directory. Invoke Java from command-line specifying target like following.

 java -jar lib/dost.jar /i:demo/book/taskbook.ditamap /transtype:pdf2


Running Environment
===================
We have tested using XSL Formatter Version 4.3.


Licensing Notes 
===============

All of the contents are donated under the Apache License Version 2.0.

 http://www.apache.org/licenses/LICENSE-2.0

Copyright notices
=================
Copyright (c) Antenna House, Inc. 2006-2008 All Rights Reserved. 
Copyright (c) IBM Corp. 2004-2006 All Rights Reserved.
Copyright (c) Idiom Technologies, Inc. 2004-2007 All rights reserved. 

Revision
=================
Oct 2008,Maintenance Release 2 for DITA Open Toolkit 1.4
  1. Added fainonerror to XSL formatter exec statement in build file.
Jul 2008, Maintenance Release 2 for DITA Open Toolkit 1.4
  1. Modified some cover title related bugs. (For IBM stylesheet).
  2. Some improvement and bug fix for index page. (For IBM stylesheet).
Jun 2008, Maintenance Release for DITA Open Toolkit 1.4
Oct 2007, Release for DITA Open Toolkit 1.4
Sep 2006, Release for DITA Open Toolkit 1.2.2


Notes
=====
1. This release is available for DITA-OT 1.421.
2. Idiom's system has problem that generates duplicate id values into 
   xxx_MERGED.xml. They are inherited into FO. XSL Formatter treats it 
   as warning error.

