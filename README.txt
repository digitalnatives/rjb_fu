rjb_fu
    by Digital Natives
    http://www.digitalnatives.hu

== DESCRIPTION:

Merged excel_fu and pdf_fu gem because of RJB
 - Excel (XLS, XLSX) handling, with RJB (Ruby Java Bridge) and Apache POI.
 - PDF generator tool, with RJB (Ruby Java Bridge) and Apache FOP.

== FEATURES/PROBLEMS:

you can define an RJB_FU_JVM_ARGS external constant in your project
default settings is:
RJB_FU_JVM_ARGS = ["-Djava.awt.headless=true"]

but you can increase java memory for example:
RJB_FU_JVM_ARGS = ["-Xms512m", "-Xmx512m", "-Djava.awt.headless=true"]


== QUESTIONS/ANSWERS:

== SYNOPSIS:

== REQUIREMENTS:

* rjb (1.2.0)

== INSTALL:

* sudo gem install rjb_fu

== LICENSE:

(The MIT License)

Copyright (c) 2011

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
