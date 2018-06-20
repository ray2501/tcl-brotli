package require Tcl 8.4
package require critcl 3.1

critcl::buildrequirement {
  package require critcl::class
}
# critcl::config language c++

critcl::license {Georgios Petasis} {BSD licensed}
critcl::summary {Brotli (de)compressor objects for Tcl.}
critcl::description {
    This package implements brotli (de)compression objects
    for Tcl.
}
critcl::subject brotli

::critcl::clibraries -lbrotlidec -lbrotlienc

critcl::class::define ::brotli {
  # include vector
  include brotli/decode.h
  include brotli/encode.h

  insvariable BrotliEncoderMode mode {} {
    instance->mode=(BrotliEncoderMode) BROTLI_DEFAULT_MODE;
  }
  insvariable int lgwin   {} {instance->lgwin   = BROTLI_DEFAULT_WINDOW;}
  insvariable int lgblock {} {instance->lgblock = -1;}
  insvariable int quality {} {instance->quality = BROTLI_DEFAULT_QUALITY;}

  method compress command {} {
    int length;
    size_t out_len;
    const uint8_t *input;
    BrotliEncoderState* state;
    uint8_t *output;
    int status;

    if (objc != 3) {
      Tcl_WrongNumArgs (interp, 2, objv, "binary_content_to_compress");
      return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    input = Tcl_GetByteArrayFromObj(objv[2], &length);
    if (!length) return TCL_OK;

    /* Get an estimation about the output buffer... */
    out_len = BrotliEncoderMaxCompressedSize(length);
    if (out_len == 0) {
      Tcl_SetResult(interp, "needed output buffer too large to encode input",
                            TCL_STATIC);
      return TCL_ERROR;
    }
    output = (uint8_t *) ckalloc(sizeof(uint8_t) * (out_len+1));
    if (output == NULL) {
      Tcl_SetResult(interp, "cannot allocate needed output buffer",
                            TCL_STATIC);
      return TCL_ERROR;
    }
    /* Compress... */
    status = BrotliEncoderCompress(instance->quality, instance->lgwin,
                                   instance->mode, length, input,
                                   &out_len, output);
    if (status) {
      Tcl_SetObjResult(interp,
          Tcl_NewByteArrayObj((unsigned char *) output, out_len));
      status =  TCL_OK;
    } else {
      Tcl_SetResult(interp, "cannot compress input", TCL_STATIC);
      status = TCL_ERROR;
    }
    ckfree((char *) output);
    return status;
  };# compress

  method decompress command {} {
    Tcl_DString output;
    int length;
    size_t input_len;
    const uint8_t *input;
    int status;

    if (objc != 3) {
      Tcl_WrongNumArgs (interp, 2, objv, "binary_content_to_decode");
      return TCL_ERROR;
    }
    Tcl_ResetResult(interp);
    input = Tcl_GetByteArrayFromObj(objv[2], &length);
    if (!length) return TCL_OK;

    Tcl_DStringInit(&output);
    BrotliDecoderState* state  = BrotliDecoderCreateInstance(0, 0, 0);
    BrotliDecoderResult result = BROTLI_DECODER_RESULT_NEEDS_MORE_OUTPUT;
    input_len = length;
    while (result == BROTLI_DECODER_RESULT_NEEDS_MORE_OUTPUT) {
      size_t available_out = 0;
      result = BrotliDecoderDecompressStream(state, &input_len, &input,
                                             &available_out, 0, 0);
      const uint8_t* next_out = BrotliDecoderTakeOutput(state,
                                                        &available_out);
      if (available_out != 0) {
        Tcl_DStringAppend(&output, next_out, available_out);
      }
    }
    status = result == BROTLI_DECODER_RESULT_SUCCESS;
    BrotliDecoderDestroyInstance(state);
    if (status) {
      Tcl_SetObjResult(interp,
          Tcl_NewByteArrayObj(Tcl_DStringValue(&output),
                              Tcl_DStringLength(&output)));
      status = TCL_OK;
    } else {
      BrotliDecoderErrorCode code = BrotliDecoderGetErrorCode(state);
      Tcl_SetResult(interp, (char *) BrotliDecoderErrorString(code),
                    TCL_DYNAMIC);
      status = TCL_ERROR;
    }
    Tcl_DStringFree(&output);
    return status;
  };# decompress

  method decoder_version command {} {
    if (objc != 2) {
      Tcl_WrongNumArgs (interp, 2, objv, NULL);
      return TCL_ERROR;
    }
    Tcl_SetObjResult(interp, Tcl_NewWideIntObj(BrotliDecoderVersion()));
    return TCL_OK;
  };# decoder_version

  method encoder_version command {} {
    if (objc != 2) {
      Tcl_WrongNumArgs (interp, 2, objv, NULL);
      return TCL_ERROR;
    }
    Tcl_SetObjResult(interp, Tcl_NewWideIntObj(BrotliEncoderVersion()));
    return TCL_OK;
  };# encoder_version

}

package provide brotli 1.0
