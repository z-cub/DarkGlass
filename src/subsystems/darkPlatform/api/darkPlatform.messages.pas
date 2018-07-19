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
unit darkPlatform.messages;

interface

type
  TPlatform = class
  public

    const MSG_PLATFORM_FIRST = $0;

    /// <summary>
    ///   Locates a log file specified by name, and returns a handle to it.
    ///   If the log file does not exist, it will be created.
    /// </summary>
    /// <param name="ParamA"> Cast as pointer, points to a pAnsiChar containing the filepath and name.</param>
    /// <param name="ParamB"></param>
    /// <param name="ParamC"></param>
    /// <param name="ParamD"></param>
    /// <returns>
    ///    Responds with a file handle for the selected log file.
    /// </returns>
    const MSG_PLATFORM_GET_LOGFILE_HANDLE = MSG_PLATFORM_FIRST + $1;

    /// <summary>
    ///   Sends a log message to the specified log file.
    /// </summary>
    /// <param name="ParamA"> Cast as pointer, points to a pAnsiChar containing the message to be logged. </param>
    /// <param name="ParamB"> A handle to a log file obtained by sending MSG_PLATFORM_GET_LOGFILE_HANDLE </param>
    /// <param name="ParamC"></param>
    /// <param name="ParamD"></param>
    /// <returns></returns>
    const MSG_PLATFORM_LOG = MSG_PLATFORM_FIRST + $2;

    ///  <summary>
    ///    Message sent by the platform when system has initialized and is
    ///    ready to begin receiving messages.
    ///  </summary>
    const MSG_PLATFORM_INITIALIZED = MSG_PLATFORM_FIRST + $4;

    /// <summary>
    ///   Send this message to the platform channel in order to create a new
    ///   window.
    /// </summary>
    /// <param name="ParamA"></param>
    /// <param name="ParamB"></param>
    /// <param name="ParamC"></param>
    /// <param name="ParamD"></param>
    /// <returns></returns>
    const MSG_PLATFORM_CREATE_WINDOW = MSG_PLATFORM_FIRST + $5;

  end;




implementation

end.
