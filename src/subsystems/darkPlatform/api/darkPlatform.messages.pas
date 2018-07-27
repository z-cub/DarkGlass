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

    ///  <summary>
    ///     Allocates a buffer of memory within the darkglass engine.
    ///     ParamA is used to specify the size of the memory buffer in bytes.
    ///  </summary>
    ///  <remark>
    ///    You may allocate a maximum of $FFFFFFFF bytes of memory.
    ///  </remark>
    ///  <param name="ParamA"> The size of the buffer to allocate in bytes. </param>
    ///  <param name="ParamB"></param>
    ///  <param name="ParamC"></param>
    ///  <param name="ParamD"></param>
    ///  <returns>
    ///    Returns a handle to the allocated buffer (or nullhandle if allocation failed.)
    ///  </returns>
    const MSG_CREATE_MEMORY_BUFFER = MSG_PLATFORM_FIRST + $1;

    /// <summary>
    ///    When passed the handle of a buffer (allocated using MSG_CREATE_MEMORY_BUFFER),
    ///    this message will return the size of the buffer in bytes.
    /// </summary>
    /// <param name="ParamA"> The handle of the buffer to query. </param>
    /// <param name="ParamB"></param>
    /// <param name="ParamC"></param>
    /// <param name="ParamD"></param>
    /// <returns>
    ///    The size of the buffer in bytes.
    /// </returns>
    const MSG_GET_BUFFER_SIZE = MSG_PLATFORM_FIRST + $2;

    /// <summary>
    ///    Returns a pointer to the memory which is managed by a buffer.
    ///    (Buffer allocated using MSG_CREATE_MEMORY_BUFFER).
    /// </summary>
    /// <param name="ParamA"> The handle of the buffer to query. </param>
    /// <param name="ParamB"></param>
    /// <param name="ParamC"></param>
    /// <param name="ParamD"></param>
    /// <returns>
    ///    A pointer to the memory managed by the specified buffer.
    /// </returns>
    const MSG_GET_BUFFER_POINTER = MSG_PLATFORM_FIRST + $3;

    /// <summary>
    ///    Create s a log file to log messages into.
    /// </summary>
    /// <param name="ParamA"> A handle to a buffer (see MSG_CREATE_MEMORY_BUFFER) containing the filename as a UTF-8 string.</param>
    /// <param name="ParamB"></param>
    /// <param name="ParamC"></param>
    /// <param name="ParamD"></param>
    /// <returns>
    ///    Returns a handle to the log file.
    /// </returns>
    const MSG_PLATFORM_GET_LOGFILE_HANDLE = MSG_PLATFORM_FIRST + $4;

    /// <summary>
    ///    Inserts an entry into a log.
    /// </summary>
    /// <param name="ParamA"> A handle to a log file. </param>
    /// <param name="ParamB"> A handle to a memory buffer (see MSG_CREATE_MEMORY_BUFFER) containing the log entry as a UTF-8 string. </param>
    /// <param name="ParamC"></param>
    /// <param name="ParamD"></param>
    /// <returns></returns>
    const MSG_PLATFORM_LOG = MSG_PLATFORM_FIRST + $5;

    ///  <summary>
    ///    Message sent by the platform when system has initialized and is
    ///    ready to begin receiving messages.
    ///  </summary>
    const MSG_PLATFORM_INITIALIZED = MSG_PLATFORM_FIRST + $6;

    /// <summary>
    ///   Send this message to the platform channel in order to create a new
    ///   window.
    /// </summary>
    /// <param name="ParamA"></param>
    /// <param name="ParamB"></param>
    /// <param name="ParamC"></param>
    /// <param name="ParamD"></param>
    /// <returns></returns>
    const MSG_PLATFORM_CREATE_WINDOW = MSG_PLATFORM_FIRST + $7;

  end;




implementation

end.
