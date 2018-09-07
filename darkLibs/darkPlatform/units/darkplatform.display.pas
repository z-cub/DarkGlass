//------------------------------------------------------------------------------
// This file is part of the DarkGlass game engine project.
// More information can be found here: http://chapmanworld.com/darkglass
//
// DarkGlass is licensed under the MIT License:
//
// Copyright 2018 Craig Chapman
//
// Permission is hereby granted, free of charge, to any person obtaining a
// copy of this software and associated documentation files (the �Software�),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED �AS IS�, WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
// OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.
//------------------------------------------------------------------------------
unit darkplatform.display;

interface

type
  IDisplay = interface
    ['{596F1AE9-E2D4-463C-A59B-3A4877FC6885}']

    /// <summary>
    ///    Returns the OS handle to the display.
    ///    If the handle can be cast as a pointer, then it will be returned
    ///    as a pointer from getOSHandle. Otherwise the result will point to
    ///    the handle.
    /// </summary>
    function getOSHandle: pointer;

    ///  <summary>
    ///    Returns a unique ID for the display at OS level.
    ///    Under linux, since Displays are actually screens, this is a pointer
    ///    to the screen number, where the getOSHandle method is a pointer
    ///    to the Display struct (display server connection).
    ///    Under other targets, this may return nil if unused.
    ///  </summary>
    function getOSID: pointer;

    ///  <summary>
    ///    Returns a string which describes the display.
    ///  </summary>
    function getName: string;

    //- Pascal Only, Properties -//
    property Name: string read getName;
  end;

implementation

end.
