//------------------------------------------------------------------------------
// This file is part of the DarkGlass game engine project.
// More information can be found here: http://chapmanworld.com/darkglass
//
// DarkGlass is licensed under the MIT License:
//
// Copyright 2018 Craig Chapman
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the “Software”),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.
//------------------------------------------------------------------------------
unit darkplatform.displaymanager;

interface
uses
  darkplatform.display;

type
  ///  <summary>
  ///    A collection representing the displays (screens) attached to the system.
  ///
  ///    Note: For disambiguation. Typically on posix based systems the word
  ///    'display' is commonly used to describe a virtual display within a
  ///    display server (x-server). This is NOT the usage used here.
  ///    The usage here is for the word 'display' to represent either a physical
  ///    screen attached to the system, or a virtual screen (or desktop) which
  ///    spans physical screens, depending on the system configuration.
  ///  </summary>
  IDisplayManager = interface
    ['{25007309-5C37-4DE7-BC6E-513B3F7FE9E9}']

    ///  <summary>
    ///    Returns the number of available displays.
    ///  </summary>
    function getCount: uint32;

    ///  <summary>
    ///    Returns an instance of IDisplay which represents the display
    ///    specified by index (idx).
    ///  </summary>
    function getDisplay( idx: uint32 ): IDisplay;

    //- Pascal Only, properties -//

    ///  <summary>
    ///    Returns the number of available displays.
    ///  </summary>
    property Count: uint32 read getCount;

    ///  <summary>
    ///    Provides array style access to the collection of IDisplay instances.
    ///  </summary>
    property Displays[ idx: uint32 ]: IDisplay read getDisplay;
  end;

implementation

end.
