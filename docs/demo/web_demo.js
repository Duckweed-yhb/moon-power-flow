function $oob() {
  throw new Error("Index out of bounds");
}
class $PanicError extends Error {}
function $panic(message) {
  throw new $PanicError(message);
}
function _M0TPB13StringBuilder(param0) {
  this.val = param0;
}
function _M0TPC16string10StringView(param0, param1, param2) {
  this.str = param0;
  this.start = param1;
  this.end = param2;
}
const _M0FPB19int__to__string__js = (x, radix) => {
  return x.toString(radix);
};
function _M0TP38Duckweed19moon_2dpower_2dflow5model2Cx(param0, param1) {
  this.re = param0;
  this.im = param1;
}
function _M0TP38Duckweed19moon_2dpower_2dflow4dist6Phasor(param0, param1, param2) {
  this.a = param0;
  this.b = param1;
  this.c = param2;
}
function _M0TP38Duckweed19moon_2dpower_2dflow4dist3Seq(param0, param1, param2) {
  this.zero = param0;
  this.positive = param1;
  this.negative = param2;
}
function _M0TPB8MutLocalGiE(param0) {
  this.val = param0;
}
function _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist8TopologyRP38Duckweed19moon_2dpower_2dflow4dist7TopoErrE3Err(param0) {
  this._0 = param0;
}
_M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist8TopologyRP38Duckweed19moon_2dpower_2dflow4dist7TopoErrE3Err.prototype.$tag = 0;
function _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist8TopologyRP38Duckweed19moon_2dpower_2dflow4dist7TopoErrE2Ok(param0) {
  this._0 = param0;
}
_M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist8TopologyRP38Duckweed19moon_2dpower_2dflow4dist7TopoErrE2Ok.prototype.$tag = 1;
function _M0DTP38Duckweed19moon_2dpower_2dflow4dist7TopoErr12RootNotFound() {}
_M0DTP38Duckweed19moon_2dpower_2dflow4dist7TopoErr12RootNotFound.prototype.$tag = 0;
const _M0DTP38Duckweed19moon_2dpower_2dflow4dist7TopoErr12RootNotFound__ = new _M0DTP38Duckweed19moon_2dpower_2dflow4dist7TopoErr12RootNotFound();
function _M0DTP38Duckweed19moon_2dpower_2dflow4dist7TopoErr15DuplicateNodeId(param0) {
  this._0 = param0;
}
_M0DTP38Duckweed19moon_2dpower_2dflow4dist7TopoErr15DuplicateNodeId.prototype.$tag = 1;
function _M0DTP38Duckweed19moon_2dpower_2dflow4dist7TopoErr15UnknownEndpoint(param0) {
  this._0 = param0;
}
_M0DTP38Duckweed19moon_2dpower_2dflow4dist7TopoErr15UnknownEndpoint.prototype.$tag = 2;
function _M0DTP38Duckweed19moon_2dpower_2dflow4dist7TopoErr9NotRadial() {}
_M0DTP38Duckweed19moon_2dpower_2dflow4dist7TopoErr9NotRadial.prototype.$tag = 3;
const _M0DTP38Duckweed19moon_2dpower_2dflow4dist7TopoErr9NotRadial__ = new _M0DTP38Duckweed19moon_2dpower_2dflow4dist7TopoErr9NotRadial();
function _M0DTP38Duckweed19moon_2dpower_2dflow4dist7TopoErr12Disconnected(param0) {
  this._0 = param0;
}
_M0DTP38Duckweed19moon_2dpower_2dflow4dist7TopoErr12Disconnected.prototype.$tag = 4;
function _M0TPB5ArrayGRPB5ArrayGUiiEEE(param0, param1) {
  this.buf = param0;
  this.len = param1;
}
function _M0TPB5ArrayGUiiEE(param0, param1) {
  this.buf = param0;
  this.len = param1;
}
function _M0TPB5ArrayGbE(param0, param1) {
  this.buf = param0;
  this.len = param1;
}
function _M0TPB5ArrayGiE(param0, param1) {
  this.buf = param0;
  this.len = param1;
}
function _M0TPB5ArrayGRPB5ArrayGiEE(param0, param1) {
  this.buf = param0;
  this.len = param1;
}
function _M0TPB8MutLocalGbE(param0) {
  this.val = param0;
}
function _M0TP38Duckweed19moon_2dpower_2dflow4dist8Topology(param0, param1, param2, param3) {
  this.order = param0;
  this.parent_edge = param1;
  this.parent = param2;
  this.children = param3;
}
function _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist7SweepOkRP38Duckweed19moon_2dpower_2dflow4dist8SweepErrE3Err(param0) {
  this._0 = param0;
}
_M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist7SweepOkRP38Duckweed19moon_2dpower_2dflow4dist8SweepErrE3Err.prototype.$tag = 0;
function _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist7SweepOkRP38Duckweed19moon_2dpower_2dflow4dist8SweepErrE2Ok(param0) {
  this._0 = param0;
}
_M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist7SweepOkRP38Duckweed19moon_2dpower_2dflow4dist8SweepErrE2Ok.prototype.$tag = 1;
function _M0DTP38Duckweed19moon_2dpower_2dflow4dist8SweepErr8Topology(param0) {
  this._0 = param0;
}
_M0DTP38Duckweed19moon_2dpower_2dflow4dist8SweepErr8Topology.prototype.$tag = 0;
function _M0DTP38Duckweed19moon_2dpower_2dflow4dist8SweepErr16TopologyMismatch() {}
_M0DTP38Duckweed19moon_2dpower_2dflow4dist8SweepErr16TopologyMismatch.prototype.$tag = 1;
const _M0DTP38Duckweed19moon_2dpower_2dflow4dist8SweepErr16TopologyMismatch__ = new _M0DTP38Duckweed19moon_2dpower_2dflow4dist8SweepErr16TopologyMismatch();
function _M0DTP38Duckweed19moon_2dpower_2dflow4dist8SweepErr9NonFinite(param0) {
  this._0 = param0;
}
_M0DTP38Duckweed19moon_2dpower_2dflow4dist8SweepErr9NonFinite.prototype.$tag = 2;
function _M0DTP38Duckweed19moon_2dpower_2dflow4dist8SweepErr13InvalidConfig() {}
_M0DTP38Duckweed19moon_2dpower_2dflow4dist8SweepErr13InvalidConfig.prototype.$tag = 3;
const _M0DTP38Duckweed19moon_2dpower_2dflow4dist8SweepErr13InvalidConfig__ = new _M0DTP38Duckweed19moon_2dpower_2dflow4dist8SweepErr13InvalidConfig();
function _M0DTP38Duckweed19moon_2dpower_2dflow4dist8SweepErr12NotConverged(param0, param1) {
  this._0 = param0;
  this._1 = param1;
}
_M0DTP38Duckweed19moon_2dpower_2dflow4dist8SweepErr12NotConverged.prototype.$tag = 4;
function _M0TPB5ArrayGRP38Duckweed19moon_2dpower_2dflow4dist6PhasorE(param0, param1) {
  this.buf = param0;
  this.len = param1;
}
function _M0TPB8MutLocalGdE(param0) {
  this.val = param0;
}
function _M0TPB5ArrayGdE(param0, param1) {
  this.buf = param0;
  this.len = param1;
}
function _M0TPB8MutLocalGRP38Duckweed19moon_2dpower_2dflow4dist6PhasorE(param0) {
  this.val = param0;
}
function _M0TP38Duckweed19moon_2dpower_2dflow4dist7SweepOk(param0, param1, param2, param3, param4) {
  this.iter = param0;
  this.voltages = param1;
  this.branch_currents = param2;
  this.max_dv = param3;
  this.trace = param4;
}
function _M0TP38Duckweed19moon_2dpower_2dflow4dist6TxSpec(param0, param1, param2) {
  this.ratio = param0;
  this.z = param1;
  this.enabled = param2;
}
function _M0TP38Duckweed19moon_2dpower_2dflow4dist8DistEdge(param0, param1, param2, param3, param4) {
  this.from_id = param0;
  this.to_id = param1;
  this.z = param2;
  this.tx = param3;
  this.sw = param4;
}
function _M0TP38Duckweed19moon_2dpower_2dflow4dist7DistNet(param0, param1, param2, param3) {
  this.nodes = param0;
  this.edges = param1;
  this.root_id = param2;
  this.v_root = param3;
}
function _M0TP38Duckweed19moon_2dpower_2dflow4dist2Z3(param0, param1, param2, param3, param4, param5) {
  this.aa = param0;
  this.bb = param1;
  this.cc = param2;
  this.ab = param3;
  this.ac = param4;
  this.bc = param5;
}
function _M0TP38Duckweed19moon_2dpower_2dflow4dist8DistNode(param0, param1) {
  this.id = param0;
  this.s = param1;
}
function _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist6TxSpecsE3Err(param0) {
  this._0 = param0;
}
_M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist6TxSpecsE3Err.prototype.$tag = 0;
function _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist6TxSpecsE2Ok(param0) {
  this._0 = param0;
}
_M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist6TxSpecsE2Ok.prototype.$tag = 1;
function _M0TP38Duckweed19moon_2dpower_2dflow4dist6Switch(param0, param1, param2) {
  this.a = param0;
  this.b = param1;
  this.c = param2;
}
function _M0TPB5ArrayGRP38Duckweed19moon_2dpower_2dflow4dist8DistNodeE(param0, param1) {
  this.buf = param0;
  this.len = param1;
}
function _M0TPB5ArrayGRP38Duckweed19moon_2dpower_2dflow4dist8DistEdgeE(param0, param1) {
  this.buf = param0;
  this.len = param1;
}
function _M0TPB8MutLocalGsE(param0) {
  this.val = param0;
}
const _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger = { method_0: _M0IPB13StringBuilderPB6Logger13write__string, method_1: _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE, method_2: _M0IPB13StringBuilderPB6Logger11write__view, method_3: _M0IPB13StringBuilderPB6Logger11write__char, method_4: _M0IP016_24default__implPB6Logger28write__string__interpolationGRPB13StringBuilderE, method_5: _M0IP016_24default__implPB6Logger5writeGRPB13StringBuilderE };
function _M0MPC15array5Array6bufferGUiiEE(self) {
  return self.buf;
}
function _M0MPC15array5Array6bufferGiE(self) {
  return self.buf;
}
function _M0MPC15array5Array6bufferGdE(self) {
  return self.buf;
}
function _M0MPC15array5Array6bufferGbE(self) {
  return self.buf;
}
function _M0MPB18UninitializedArray6lengthGUiiEE(self) {
  return self.length;
}
function _M0MPB18UninitializedArray6lengthGiE(self) {
  return self.length;
}
function _M0MPB18UninitializedArray6lengthGdE(self) {
  return self.length;
}
function _M0MPB18UninitializedArray6lengthGbE(self) {
  return self.length;
}
function _M0MPC15array10FixedArray12unsafe__blitGRPB17UnsafeMaybeUninitGRPB5ArrayGiEEE(dst, dst_offset, src, src_offset, len) {
  if (dst === src && dst_offset < src_offset) {
    let _tmp = 0;
    while (true) {
      const i = _tmp;
      if (i < len) {
        const _tmp$2 = dst_offset + i | 0;
        const _tmp$3 = src_offset + i | 0;
        if (_tmp$2 >>> 0 < dst.length) {
          dst[_tmp$2] = _tmp$3 >>> 0 < src.length ? src[_tmp$3] : $oob();
        } else {
          $oob();
        }
        _tmp = i + 1 | 0;
        continue;
      } else {
        return;
      }
    }
  } else {
    let _tmp = len - 1 | 0;
    let _tmp$2 = len > 0;
    while (true) {
      const i = _tmp;
      const _more = _tmp$2;
      if (_more) {
        const _tmp$3 = dst_offset + i | 0;
        const _tmp$4 = src_offset + i | 0;
        if (_tmp$3 >>> 0 < dst.length) {
          dst[_tmp$3] = _tmp$4 >>> 0 < src.length ? src[_tmp$4] : $oob();
        } else {
          $oob();
        }
        _tmp = i - 1 | 0;
        _tmp$2 = i > 0;
        continue;
      } else {
        return;
      }
    }
  }
}
function _M0MPC15array10FixedArray12unsafe__blitGRPB17UnsafeMaybeUninitGiEE(dst, dst_offset, src, src_offset, len) {
  if (dst === src && dst_offset < src_offset) {
    let _tmp = 0;
    while (true) {
      const i = _tmp;
      if (i < len) {
        const _tmp$2 = dst_offset + i | 0;
        const _tmp$3 = src_offset + i | 0;
        if (_tmp$2 >>> 0 < dst.length) {
          dst[_tmp$2] = _tmp$3 >>> 0 < src.length ? src[_tmp$3] : $oob();
        } else {
          $oob();
        }
        _tmp = i + 1 | 0;
        continue;
      } else {
        return;
      }
    }
  } else {
    let _tmp = len - 1 | 0;
    let _tmp$2 = len > 0;
    while (true) {
      const i = _tmp;
      const _more = _tmp$2;
      if (_more) {
        const _tmp$3 = dst_offset + i | 0;
        const _tmp$4 = src_offset + i | 0;
        if (_tmp$3 >>> 0 < dst.length) {
          dst[_tmp$3] = _tmp$4 >>> 0 < src.length ? src[_tmp$4] : $oob();
        } else {
          $oob();
        }
        _tmp = i - 1 | 0;
        _tmp$2 = i > 0;
        continue;
      } else {
        return;
      }
    }
  }
}
function _M0MPC15array10FixedArray12unsafe__blitGRPB17UnsafeMaybeUninitGdEE(dst, dst_offset, src, src_offset, len) {
  if (dst === src && dst_offset < src_offset) {
    let _tmp = 0;
    while (true) {
      const i = _tmp;
      if (i < len) {
        const _tmp$2 = dst_offset + i | 0;
        const _tmp$3 = src_offset + i | 0;
        if (_tmp$2 >>> 0 < dst.length) {
          dst[_tmp$2] = _tmp$3 >>> 0 < src.length ? src[_tmp$3] : $oob();
        } else {
          $oob();
        }
        _tmp = i + 1 | 0;
        continue;
      } else {
        return;
      }
    }
  } else {
    let _tmp = len - 1 | 0;
    let _tmp$2 = len > 0;
    while (true) {
      const i = _tmp;
      const _more = _tmp$2;
      if (_more) {
        const _tmp$3 = dst_offset + i | 0;
        const _tmp$4 = src_offset + i | 0;
        if (_tmp$3 >>> 0 < dst.length) {
          dst[_tmp$3] = _tmp$4 >>> 0 < src.length ? src[_tmp$4] : $oob();
        } else {
          $oob();
        }
        _tmp = i - 1 | 0;
        _tmp$2 = i > 0;
        continue;
      } else {
        return;
      }
    }
  }
}
function _M0MPC15array10FixedArray12unsafe__blitGRPB17UnsafeMaybeUninitGbEE(dst, dst_offset, src, src_offset, len) {
  if (dst === src && dst_offset < src_offset) {
    let _tmp = 0;
    while (true) {
      const i = _tmp;
      if (i < len) {
        const _tmp$2 = dst_offset + i | 0;
        const _tmp$3 = src_offset + i | 0;
        if (_tmp$2 >>> 0 < dst.length) {
          dst[_tmp$2] = _tmp$3 >>> 0 < src.length ? src[_tmp$3] : $oob();
        } else {
          $oob();
        }
        _tmp = i + 1 | 0;
        continue;
      } else {
        return;
      }
    }
  } else {
    let _tmp = len - 1 | 0;
    let _tmp$2 = len > 0;
    while (true) {
      const i = _tmp;
      const _more = _tmp$2;
      if (_more) {
        const _tmp$3 = dst_offset + i | 0;
        const _tmp$4 = src_offset + i | 0;
        if (_tmp$3 >>> 0 < dst.length) {
          dst[_tmp$3] = _tmp$4 >>> 0 < src.length ? src[_tmp$4] : $oob();
        } else {
          $oob();
        }
        _tmp = i - 1 | 0;
        _tmp$2 = i > 0;
        continue;
      } else {
        return;
      }
    }
  }
}
function _M0MPB18UninitializedArray12unsafe__blitGUiiEE(dst, dst_offset, src, src_offset, len) {
  _M0MPC15array10FixedArray12unsafe__blitGRPB17UnsafeMaybeUninitGRPB5ArrayGiEEE(dst, dst_offset, src, src_offset, len);
}
function _M0MPB18UninitializedArray12unsafe__blitGiE(dst, dst_offset, src, src_offset, len) {
  _M0MPC15array10FixedArray12unsafe__blitGRPB17UnsafeMaybeUninitGiEE(dst, dst_offset, src, src_offset, len);
}
function _M0MPB18UninitializedArray12unsafe__blitGdE(dst, dst_offset, src, src_offset, len) {
  _M0MPC15array10FixedArray12unsafe__blitGRPB17UnsafeMaybeUninitGdEE(dst, dst_offset, src, src_offset, len);
}
function _M0MPB18UninitializedArray12unsafe__blitGbE(dst, dst_offset, src, src_offset, len) {
  _M0MPC15array10FixedArray12unsafe__blitGRPB17UnsafeMaybeUninitGbEE(dst, dst_offset, src, src_offset, len);
}
function _M0MPB18UninitializedArray23unsafe__make__and__blitGUiiEE(src, allocate_len, src_offset, dst_offset, blit_len) {
  const dst = new Array(allocate_len);
  _M0MPB18UninitializedArray12unsafe__blitGUiiEE(dst, dst_offset, src, src_offset, blit_len);
  return dst;
}
function _M0MPB18UninitializedArray23unsafe__make__and__blitGiE(src, allocate_len, src_offset, dst_offset, blit_len) {
  const dst = new Array(allocate_len);
  _M0MPB18UninitializedArray12unsafe__blitGiE(dst, dst_offset, src, src_offset, blit_len);
  return dst;
}
function _M0MPB18UninitializedArray23unsafe__make__and__blitGdE(src, allocate_len, src_offset, dst_offset, blit_len) {
  const dst = new Array(allocate_len);
  _M0MPB18UninitializedArray12unsafe__blitGdE(dst, dst_offset, src, src_offset, blit_len);
  return dst;
}
function _M0MPB18UninitializedArray23unsafe__make__and__blitGbE(src, allocate_len, src_offset, dst_offset, blit_len) {
  const dst = new Array(allocate_len);
  _M0MPB18UninitializedArray12unsafe__blitGbE(dst, dst_offset, src, src_offset, blit_len);
  return dst;
}
function _M0FPB11range__fits(offset, len, length) {
  return offset >= 0 && offset <= (length - len | 0);
}
function _M0MPB13StringBuilder13write__objectGiE(self, obj) {
  _M0IP016_24default__implPB4Show6outputGiE(obj, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0MPB18UninitializedArray23make__and__blit_2einnerGUiiEE(src, allocate_len, len, src_offset, dst_offset) {
  if (allocate_len >= 0 && (len >= 0 && (_M0FPB11range__fits(src_offset, len, _M0MPB18UninitializedArray6lengthGUiiEE(src)) && _M0FPB11range__fits(dst_offset, len, allocate_len)))) {
    return _M0MPB18UninitializedArray23unsafe__make__and__blitGUiiEE(src, allocate_len, src_offset, dst_offset, len);
  } else {
    const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(89);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "bounds check failed: allocate_len = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, allocate_len);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", src_offset = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, src_offset);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", dst_offset = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, dst_offset);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", len = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, len);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", src.length = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, _M0MPB18UninitializedArray6lengthGUiiEE(src));
    return $panic(_M0MPB13StringBuilder10to__string(_string_builder));
  }
}
function _M0MPB18UninitializedArray23make__and__blit_2einnerGiE(src, allocate_len, len, src_offset, dst_offset) {
  if (allocate_len >= 0 && (len >= 0 && (_M0FPB11range__fits(src_offset, len, _M0MPB18UninitializedArray6lengthGiE(src)) && _M0FPB11range__fits(dst_offset, len, allocate_len)))) {
    return _M0MPB18UninitializedArray23unsafe__make__and__blitGiE(src, allocate_len, src_offset, dst_offset, len);
  } else {
    const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(89);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "bounds check failed: allocate_len = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, allocate_len);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", src_offset = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, src_offset);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", dst_offset = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, dst_offset);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", len = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, len);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", src.length = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, _M0MPB18UninitializedArray6lengthGiE(src));
    return $panic(_M0MPB13StringBuilder10to__string(_string_builder));
  }
}
function _M0MPB18UninitializedArray23make__and__blit_2einnerGdE(src, allocate_len, len, src_offset, dst_offset) {
  if (allocate_len >= 0 && (len >= 0 && (_M0FPB11range__fits(src_offset, len, _M0MPB18UninitializedArray6lengthGdE(src)) && _M0FPB11range__fits(dst_offset, len, allocate_len)))) {
    return _M0MPB18UninitializedArray23unsafe__make__and__blitGdE(src, allocate_len, src_offset, dst_offset, len);
  } else {
    const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(89);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "bounds check failed: allocate_len = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, allocate_len);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", src_offset = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, src_offset);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", dst_offset = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, dst_offset);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", len = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, len);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", src.length = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, _M0MPB18UninitializedArray6lengthGdE(src));
    return $panic(_M0MPB13StringBuilder10to__string(_string_builder));
  }
}
function _M0MPB18UninitializedArray23make__and__blit_2einnerGbE(src, allocate_len, len, src_offset, dst_offset) {
  if (allocate_len >= 0 && (len >= 0 && (_M0FPB11range__fits(src_offset, len, _M0MPB18UninitializedArray6lengthGbE(src)) && _M0FPB11range__fits(dst_offset, len, allocate_len)))) {
    return _M0MPB18UninitializedArray23unsafe__make__and__blitGbE(src, allocate_len, src_offset, dst_offset, len);
  } else {
    const _string_builder = _M0MPB13StringBuilder21StringBuilder_2einner(89);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, "bounds check failed: allocate_len = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, allocate_len);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", src_offset = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, src_offset);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", dst_offset = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, dst_offset);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", len = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, len);
    _M0IPB13StringBuilderPB6Logger13write__string(_string_builder, ", src.length = ");
    _M0MPB13StringBuilder13write__objectGiE(_string_builder, _M0MPB18UninitializedArray6lengthGbE(src));
    return $panic(_M0MPB13StringBuilder10to__string(_string_builder));
  }
}
function _M0MPB13StringBuilder21StringBuilder_2einner(size_hint) {
  return size_hint >= 0 ? new _M0TPB13StringBuilder("") : $panic("size_hint must be non-negative");
}
function _M0MPB13StringBuilder10to__string(self) {
  return self.val;
}
function _M0IPB13StringBuilderPB6Logger11write__char(self, ch) {
  self.val = `${self.val}${String.fromCodePoint(ch)}`;
}
function _M0IPB13StringBuilderPB6Logger13write__string(self, str) {
  self.val = `${self.val}${str}`;
}
function _M0MPC16uint166UInt1622is__leading__surrogate(self) {
  return self >= 55296 && self <= 56319;
}
function _M0MPC16uint166UInt1623is__trailing__surrogate(self) {
  return self >= 56320 && self <= 57343;
}
function _M0IP016_24default__implPB6Logger28write__string__interpolationGRPB13StringBuilderE(self, show) {
  show.method_table.method_0(show.self, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0IP016_24default__implPB6Logger5writeGRPB13StringBuilderE(self, show) {
  show.method_table.method_0(show.self, { self: self, method_table: _M0FP092moonbitlang_2fcore_2fbuiltin_2fStringBuilder_24as_24_40moonbitlang_2fcore_2fbuiltin_2eLogger });
}
function _M0MPC16string6String21clamped__view_2einner(self, start, end) {
  const len = self.length;
  const lo = start <= 0 ? 0 : start >= len ? len : _M0MPC16uint166UInt1623is__trailing__surrogate(self.charCodeAt(start)) && _M0MPC16uint166UInt1622is__leading__surrogate(self.charCodeAt(start - 1 | 0)) ? start + 1 | 0 : start;
  let hi;
  if (end === undefined) {
    hi = len;
  } else {
    const _Some = end;
    const _e = _Some;
    hi = _e <= 0 ? 0 : _e >= len ? len : _M0MPC16uint166UInt1623is__trailing__surrogate(self.charCodeAt(_e)) && _M0MPC16uint166UInt1622is__leading__surrogate(self.charCodeAt(_e - 1 | 0)) ? _e - 1 | 0 : _e;
  }
  return lo >= hi ? new _M0TPC16string10StringView(self, lo, lo) : new _M0TPC16string10StringView(self, lo, hi);
}
function _M0IP016_24default__implPB6Logger16write__substringGRPB13StringBuilderE(self, value, start, len) {
  _M0IPB13StringBuilderPB6Logger11write__view(self, _M0MPC16string6String21clamped__view_2einner(value, start, start + len | 0));
}
function _M0IP016_24default__implPB4Show6outputGiE(self, logger) {
  logger.method_table.method_0(logger.self, _M0IPC13int3IntPB4Show10to__string(self));
}
function _M0MPC13int3Int18to__string_2einner(self, radix) {
  return _M0FPB19int__to__string__js(self, radix);
}
function _M0MPC16string10StringView9to__owned(self) {
  return self.str.substring(self.start, self.end);
}
function _M0IPB13StringBuilderPB6Logger11write__view(self, str) {
  self.val = `${self.val}${_M0MPC16string10StringView9to__owned(str)}`;
}
function _M0IPC16string6StringPB4Show10to__string(self) {
  return self;
}
function _M0MPC15array5Array6lengthGiE(self) {
  return self.len;
}
function _M0MPC15array5Array6lengthGdE(self) {
  return self.len;
}
function _M0MPC15array5Array6lengthGRP38Duckweed19moon_2dpower_2dflow4dist6PhasorE(self) {
  return self.len;
}
function _M0FPB23array__growth__capacity(current, len, required) {
  if (required < len) {
    $panic("Array capacity overflow");
  }
  const start = current === 0 ? 8 : current;
  let _tmp = start;
  while (true) {
    const space = _tmp;
    if (space < required) {
      const next = Math.imul(space, 2) | 0;
      if (next <= space) {
        return required;
      }
      _tmp = next;
      continue;
    } else {
      return space;
    }
  }
}
function _M0MPC15array5Array8capacityGUiiEE(self) {
  return _M0MPC15array5Array6bufferGUiiEE(self).length;
}
function _M0MPC15array5Array8capacityGiE(self) {
  return _M0MPC15array5Array6bufferGiE(self).length;
}
function _M0MPC15array5Array8capacityGdE(self) {
  return _M0MPC15array5Array6bufferGdE(self).length;
}
function _M0MPC15array5Array8capacityGbE(self) {
  return _M0MPC15array5Array6bufferGbE(self).length;
}
function _M0MPC15array5Array14resize__bufferGUiiEE(self, new_capacity) {
  const old_buf = self.buf;
  self.buf = [];
  const len = self.len;
  const copy_len = len < new_capacity ? len : new_capacity;
  const new_buf = _M0MPB18UninitializedArray23make__and__blit_2einnerGUiiEE(old_buf, new_capacity, copy_len, 0, 0);
  self.buf = new_buf;
}
function _M0MPC15array5Array14resize__bufferGiE(self, new_capacity) {
  const old_buf = self.buf;
  self.buf = [];
  const len = self.len;
  const copy_len = len < new_capacity ? len : new_capacity;
  const new_buf = _M0MPB18UninitializedArray23make__and__blit_2einnerGiE(old_buf, new_capacity, copy_len, 0, 0);
  self.buf = new_buf;
}
function _M0MPC15array5Array14resize__bufferGdE(self, new_capacity) {
  const old_buf = self.buf;
  self.buf = [];
  const len = self.len;
  const copy_len = len < new_capacity ? len : new_capacity;
  const new_buf = _M0MPB18UninitializedArray23make__and__blit_2einnerGdE(old_buf, new_capacity, copy_len, 0, 0);
  self.buf = new_buf;
}
function _M0MPC15array5Array14resize__bufferGbE(self, new_capacity) {
  const old_buf = self.buf;
  self.buf = [];
  const len = self.len;
  const copy_len = len < new_capacity ? len : new_capacity;
  const new_buf = _M0MPB18UninitializedArray23make__and__blit_2einnerGbE(old_buf, new_capacity, copy_len, 0, 0);
  self.buf = new_buf;
}
function _M0MPC15array5Array7reallocGUiiEE(self, required) {
  const old_cap = _M0MPC15array5Array8capacityGUiiEE(self);
  const new_cap = _M0FPB23array__growth__capacity(old_cap, self.len, required);
  _M0MPC15array5Array14resize__bufferGUiiEE(self, new_cap);
}
function _M0MPC15array5Array7reallocGiE(self, required) {
  const old_cap = _M0MPC15array5Array8capacityGiE(self);
  const new_cap = _M0FPB23array__growth__capacity(old_cap, self.len, required);
  _M0MPC15array5Array14resize__bufferGiE(self, new_cap);
}
function _M0MPC15array5Array7reallocGdE(self, required) {
  const old_cap = _M0MPC15array5Array8capacityGdE(self);
  const new_cap = _M0FPB23array__growth__capacity(old_cap, self.len, required);
  _M0MPC15array5Array14resize__bufferGdE(self, new_cap);
}
function _M0MPC15array5Array7reallocGbE(self, required) {
  const old_cap = _M0MPC15array5Array8capacityGbE(self);
  const new_cap = _M0FPB23array__growth__capacity(old_cap, self.len, required);
  _M0MPC15array5Array14resize__bufferGbE(self, new_cap);
}
function _M0MPC15array5Array4pushGUiiEE(self, value) {
  if (self.len === _M0MPC15array5Array6bufferGUiiEE(self).length) {
    _M0MPC15array5Array7reallocGUiiEE(self, self.len + 1 | 0);
  }
  const length = self.len;
  self.buf[length] = value;
  self.len = length + 1 | 0;
}
function _M0MPC15array5Array4pushGiE(self, value) {
  if (self.len === _M0MPC15array5Array6bufferGiE(self).length) {
    _M0MPC15array5Array7reallocGiE(self, self.len + 1 | 0);
  }
  const length = self.len;
  self.buf[length] = value;
  self.len = length + 1 | 0;
}
function _M0MPC15array5Array4pushGdE(self, value) {
  if (self.len === _M0MPC15array5Array6bufferGdE(self).length) {
    _M0MPC15array5Array7reallocGdE(self, self.len + 1 | 0);
  }
  const length = self.len;
  self.buf[length] = value;
  self.len = length + 1 | 0;
}
function _M0MPC15array5Array4pushGbE(self, value) {
  if (self.len === _M0MPC15array5Array6bufferGbE(self).length) {
    _M0MPC15array5Array7reallocGbE(self, self.len + 1 | 0);
  }
  const length = self.len;
  self.buf[length] = value;
  self.len = length + 1 | 0;
}
function _M0IPC13int3IntPB4Show10to__string(self) {
  return _M0MPC13int3Int18to__string_2einner(self, 10);
}
function _M0MPC16double6Double5round(_tmp) {
  return Math.round(_tmp);
}
function _M0MPC15array5Array2atGiE(self, index) {
  const len = self.len;
  return index >= 0 && index < len ? _M0MPC15array5Array6bufferGiE(self)[index] : $panic();
}
function _M0MPC15array5Array2atGRPB5ArrayGUiiEEE(self, index) {
  const len = self.len;
  return index >= 0 && index < len ? _M0MPC15array5Array6bufferGUiiEE(self)[index] : $panic();
}
function _M0MPC15array5Array2atGdE(self, index) {
  const len = self.len;
  return index >= 0 && index < len ? _M0MPC15array5Array6bufferGdE(self)[index] : $panic();
}
function _M0MPC15array5Array2atGbE(self, index) {
  const len = self.len;
  return index >= 0 && index < len ? _M0MPC15array5Array6bufferGbE(self)[index] : $panic();
}
function _M0FPB7printlnGsE(input) {
  console.log(_M0IPC16string6StringPB4Show10to__string(input));
}
function _M0MPC15array5Array3setGiE(self, index, value) {
  const len = self.len;
  if (index >= 0 && index < len) {
    _M0MPC15array5Array6bufferGiE(self)[index] = value;
    return;
  } else {
    $panic();
    return;
  }
}
function _M0MPC15array5Array3setGRP38Duckweed19moon_2dpower_2dflow4dist6PhasorE(self, index, value) {
  const len = self.len;
  if (index >= 0 && index < len) {
    _M0MPC15array5Array6bufferGUiiEE(self)[index] = value;
    return;
  } else {
    $panic();
    return;
  }
}
function _M0MPC15array5Array3setGbE(self, index, value) {
  const len = self.len;
  if (index >= 0 && index < len) {
    _M0MPC15array5Array6bufferGbE(self)[index] = value;
    return;
  } else {
    $panic();
    return;
  }
}
function _M0FPC14math3sin(_tmp) {
  return Math.sin(_tmp);
}
function _M0FPC14math3cos(_tmp) {
  return Math.cos(_tmp);
}
function _M0MP38Duckweed19moon_2dpower_2dflow5model3Zip9scale__at(self, v_mag) {
  return self.alpha + self.beta * v_mag + self.gamma * v_mag * v_mag;
}
function _M0FP38Duckweed19moon_2dpower_2dflow5model2cx(re, im) {
  return new _M0TP38Duckweed19moon_2dpower_2dflow5model2Cx(re, im);
}
function _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__add(a, b) {
  return _M0FP38Duckweed19moon_2dpower_2dflow5model2cx(a.re + b.re, a.im + b.im);
}
function _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__sub(a, b) {
  return _M0FP38Duckweed19moon_2dpower_2dflow5model2cx(a.re - b.re, a.im - b.im);
}
function _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__mul(a, b) {
  return _M0FP38Duckweed19moon_2dpower_2dflow5model2cx(a.re * b.re - a.im * b.im, a.re * b.im + a.im * b.re);
}
function _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__div(a, b) {
  const denom = b.re * b.re + b.im * b.im;
  return _M0FP38Duckweed19moon_2dpower_2dflow5model2cx((a.re * b.re + a.im * b.im) / denom, (a.im * b.re - a.re * b.im) / denom);
}
function _M0FP38Duckweed19moon_2dpower_2dflow5model8cx__conj(a) {
  return _M0FP38Duckweed19moon_2dpower_2dflow5model2cx(a.re, -a.im);
}
function _M0FP38Duckweed19moon_2dpower_2dflow5model9cx__scale(a, k) {
  return _M0FP38Duckweed19moon_2dpower_2dflow5model2cx(a.re * k, a.im * k);
}
function _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__abs(a) {
  return Math.sqrt(a.re * a.re + a.im * a.im);
}
function _M0FP38Duckweed19moon_2dpower_2dflow5model9cx__polar(mag, angle) {
  return _M0FP38Duckweed19moon_2dpower_2dflow5model2cx(mag * _M0FPC14math3cos(angle), mag * _M0FPC14math3sin(angle));
}
function _M0FP38Duckweed19moon_2dpower_2dflow4dist6phasor(a, b, c) {
  return new _M0TP38Duckweed19moon_2dpower_2dflow4dist6Phasor(a, b, c);
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor1a(self) {
  return self.a;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor1b(self) {
  return self.b;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor1c(self) {
  return self.c;
}
function _M0FP38Duckweed19moon_2dpower_2dflow4dist17zip__adjust__load(s, v, zip) {
  const fa = _M0MP38Duckweed19moon_2dpower_2dflow5model3Zip9scale__at(zip, _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__abs(_M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor1a(v)));
  const fb = _M0MP38Duckweed19moon_2dpower_2dflow5model3Zip9scale__at(zip, _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__abs(_M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor1b(v)));
  const fc = _M0MP38Duckweed19moon_2dpower_2dflow5model3Zip9scale__at(zip, _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__abs(_M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor1c(v)));
  return _M0FP38Duckweed19moon_2dpower_2dflow4dist6phasor(_M0FP38Duckweed19moon_2dpower_2dflow5model9cx__scale(_M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor1a(s), fa), _M0FP38Duckweed19moon_2dpower_2dflow5model9cx__scale(_M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor1b(s), fb), _M0FP38Duckweed19moon_2dpower_2dflow5model9cx__scale(_M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor1c(s), fc));
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet8node__at(self, i) {
  return _M0MPC15array5Array2atGRPB5ArrayGUiiEEE(self.nodes, i);
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet11node__count(self) {
  return _M0MPC15array5Array6lengthGRP38Duckweed19moon_2dpower_2dflow4dist6PhasorE(self.nodes);
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet8root__id(self) {
  return self.root_id;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistNode2id(self) {
  return self.id;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistNode1s(self) {
  return self.s;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist7SweepOk8voltages(self) {
  return self.voltages;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor4conj(self) {
  return new _M0TP38Duckweed19moon_2dpower_2dflow4dist6Phasor(_M0FP38Duckweed19moon_2dpower_2dflow5model8cx__conj(self.a), _M0FP38Duckweed19moon_2dpower_2dflow5model8cx__conj(self.b), _M0FP38Duckweed19moon_2dpower_2dflow5model8cx__conj(self.c));
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor8map__div(self, den) {
  return new _M0TP38Duckweed19moon_2dpower_2dflow4dist6Phasor(_M0FP38Duckweed19moon_2dpower_2dflow5model7cx__div(self.a, den.a), _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__div(self.b, den.b), _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__div(self.c, den.c));
}
function _M0FP38Duckweed19moon_2dpower_2dflow4dist13load__current(s, v, zip) {
  let z;
  _L: {
    if (zip === undefined) {
      return _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor4conj(_M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor8map__div(s, v));
    } else {
      const _Some = zip;
      const _z = _Some;
      z = _z;
      break _L;
    }
  }
  return _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor4conj(_M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor8map__div(_M0FP38Duckweed19moon_2dpower_2dflow4dist17zip__adjust__load(s, v, z), v));
}
function _M0FP38Duckweed19moon_2dpower_2dflow4dist6rot__a() {
  return _M0FP38Duckweed19moon_2dpower_2dflow5model2cx(-0.5, 0.8660254037844386);
}
function _M0FP38Duckweed19moon_2dpower_2dflow4dist23symmetrical__components(v) {
  const a = _M0FP38Duckweed19moon_2dpower_2dflow4dist6rot__a();
  const a2 = _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__mul(a, a);
  const va = _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor1a(v);
  const vb = _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor1b(v);
  const vc = _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor1c(v);
  const third = 0.33333333333333331;
  const zero = _M0FP38Duckweed19moon_2dpower_2dflow5model9cx__scale(_M0FP38Duckweed19moon_2dpower_2dflow5model7cx__add(_M0FP38Duckweed19moon_2dpower_2dflow5model7cx__add(va, vb), vc), third);
  const positive = _M0FP38Duckweed19moon_2dpower_2dflow5model9cx__scale(_M0FP38Duckweed19moon_2dpower_2dflow5model7cx__add(_M0FP38Duckweed19moon_2dpower_2dflow5model7cx__add(va, _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__mul(a, vb)), _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__mul(a2, vc)), third);
  const negative = _M0FP38Duckweed19moon_2dpower_2dflow5model9cx__scale(_M0FP38Duckweed19moon_2dpower_2dflow5model7cx__add(_M0FP38Duckweed19moon_2dpower_2dflow5model7cx__add(va, _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__mul(a2, vb)), _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__mul(a, vc)), third);
  return new _M0TP38Duckweed19moon_2dpower_2dflow4dist3Seq(zero, positive, negative);
}
function _M0FP38Duckweed19moon_2dpower_2dflow4dist27voltage__unbalance__percent(v) {
  const seq = _M0FP38Duckweed19moon_2dpower_2dflow4dist23symmetrical__components(v);
  const pos = _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__abs(seq.positive);
  if (pos < 1e-012) {
    return 0;
  }
  return _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__abs(seq.negative) / pos * 100;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist7TopoErr8describe(self) {
  let id;
  _L: {
    let id$2;
    _L$2: {
      let id$3;
      _L$3: {
        switch (self.$tag) {
          case 0: {
            return "root bus not found";
          }
          case 1: {
            const _DuplicateNodeId = self;
            const _id = _DuplicateNodeId._0;
            id$3 = _id;
            break _L$3;
          }
          case 2: {
            const _UnknownEndpoint = self;
            const _id$2 = _UnknownEndpoint._0;
            id$2 = _id$2;
            break _L$2;
          }
          case 3: {
            return "branch count != node count - 1, network is not radial";
          }
          default: {
            const _Disconnected = self;
            const _id$3 = _Disconnected._0;
            id = _id$3;
            break _L;
          }
        }
      }
      return `duplicate node id ${_M0MPC13int3Int18to__string_2einner(id$3, 10)}`;
    }
    return `branch references unknown node id ${_M0MPC13int3Int18to__string_2einner(id$2, 10)}`;
  }
  return `node ${_M0MPC13int3Int18to__string_2einner(id, 10)} is not reachable from root`;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist8Topology5order(self) {
  return self.order;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist8Topology12parent__edge(self) {
  return self.parent_edge;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist8Topology6parent(self) {
  return self.parent;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist8Topology8children(self) {
  return self.children;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge8from__id(self) {
  return self.from_id;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge6to__id(self) {
  return self.to_id;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet8edge__at(self, k) {
  return _M0MPC15array5Array2atGRPB5ArrayGUiiEEE(self.edges, k);
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet11edge__count(self) {
  return _M0MPC15array5Array6lengthGRP38Duckweed19moon_2dpower_2dflow4dist6PhasorE(self.edges);
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet11find__index(self, id) {
  const n = _M0MPC15array5Array6lengthGRP38Duckweed19moon_2dpower_2dflow4dist6PhasorE(self.nodes);
  const i = new _M0TPB8MutLocalGiE(0);
  while (true) {
    if (i.val < n) {
      if (_M0MPC15array5Array2atGRPB5ArrayGUiiEEE(self.nodes, i.val).id === id) {
        return i.val;
      }
      i.val = i.val + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return undefined;
}
function _M0FP38Duckweed19moon_2dpower_2dflow4dist15build__topology(net) {
  const n = _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet11node__count(net);
  if (n === 0) {
    return new _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist8TopologyRP38Duckweed19moon_2dpower_2dflow4dist7TopoErrE3Err(_M0DTP38Duckweed19moon_2dpower_2dflow4dist7TopoErr12RootNotFound__);
  }
  const i = new _M0TPB8MutLocalGiE(0);
  while (true) {
    if (i.val < n) {
      const j = new _M0TPB8MutLocalGiE(i.val + 1 | 0);
      while (true) {
        if (j.val < n) {
          if (_M0MP38Duckweed19moon_2dpower_2dflow4dist8DistNode2id(_M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet8node__at(net, i.val)) === _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistNode2id(_M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet8node__at(net, j.val))) {
            return new _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist8TopologyRP38Duckweed19moon_2dpower_2dflow4dist7TopoErrE3Err(new _M0DTP38Duckweed19moon_2dpower_2dflow4dist7TopoErr15DuplicateNodeId(_M0MP38Duckweed19moon_2dpower_2dflow4dist8DistNode2id(_M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet8node__at(net, i.val))));
          }
          j.val = j.val + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      i.val = i.val + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  let root;
  const _bind = _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet11find__index(net, _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet8root__id(net));
  if (_bind === undefined) {
    return new _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist8TopologyRP38Duckweed19moon_2dpower_2dflow4dist7TopoErrE3Err(_M0DTP38Duckweed19moon_2dpower_2dflow4dist7TopoErr12RootNotFound__);
  } else {
    const _Some = _bind;
    const _k = _Some;
    root = _k;
  }
  const m = _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet11edge__count(net);
  const k = new _M0TPB8MutLocalGiE(0);
  while (true) {
    if (k.val < m) {
      const e = _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet8edge__at(net, k.val);
      const _bind$2 = _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet11find__index(net, _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge8from__id(e));
      if (_bind$2 === undefined) {
        return new _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist8TopologyRP38Duckweed19moon_2dpower_2dflow4dist7TopoErrE3Err(new _M0DTP38Duckweed19moon_2dpower_2dflow4dist7TopoErr15UnknownEndpoint(_M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge8from__id(e)));
      }
      const _bind$3 = _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet11find__index(net, _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge6to__id(e));
      if (_bind$3 === undefined) {
        return new _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist8TopologyRP38Duckweed19moon_2dpower_2dflow4dist7TopoErrE3Err(new _M0DTP38Duckweed19moon_2dpower_2dflow4dist7TopoErr15UnknownEndpoint(_M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge6to__id(e)));
      }
      k.val = k.val + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  if (m !== (n - 1 | 0)) {
    return new _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist8TopologyRP38Duckweed19moon_2dpower_2dflow4dist7TopoErrE3Err(_M0DTP38Duckweed19moon_2dpower_2dflow4dist7TopoErr9NotRadial__);
  }
  const adj = new _M0TPB5ArrayGRPB5ArrayGUiiEEE([], 0);
  const _bind$2 = 0;
  let _tmp = _bind$2;
  while (true) {
    const _ = _tmp;
    if (_ < n) {
      _M0MPC15array5Array4pushGUiiEE(adj, new _M0TPB5ArrayGUiiEE([], 0));
      _tmp = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const e = new _M0TPB8MutLocalGiE(0);
  while (true) {
    if (e.val < m) {
      const edge = _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet8edge__at(net, e.val);
      let u;
      const _bind$3 = _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet11find__index(net, _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge8from__id(edge));
      if (_bind$3 === undefined) {
        return new _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist8TopologyRP38Duckweed19moon_2dpower_2dflow4dist7TopoErrE3Err(new _M0DTP38Duckweed19moon_2dpower_2dflow4dist7TopoErr15UnknownEndpoint(_M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge8from__id(edge)));
      } else {
        const _Some = _bind$3;
        const _x = _Some;
        u = _x;
      }
      let v;
      const _bind$4 = _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet11find__index(net, _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge6to__id(edge));
      if (_bind$4 === undefined) {
        return new _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist8TopologyRP38Duckweed19moon_2dpower_2dflow4dist7TopoErrE3Err(new _M0DTP38Duckweed19moon_2dpower_2dflow4dist7TopoErr15UnknownEndpoint(_M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge6to__id(edge)));
      } else {
        const _Some = _bind$4;
        const _x = _Some;
        v = _x;
      }
      _M0MPC15array5Array4pushGUiiEE(_M0MPC15array5Array2atGRPB5ArrayGUiiEEE(adj, u), { _0: v, _1: e.val });
      _M0MPC15array5Array4pushGUiiEE(_M0MPC15array5Array2atGRPB5ArrayGUiiEEE(adj, v), { _0: u, _1: e.val });
      e.val = e.val + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const visited = new _M0TPB5ArrayGbE([], 0);
  const _bind$3 = 0;
  let _tmp$2 = _bind$3;
  while (true) {
    const _ = _tmp$2;
    if (_ < n) {
      _M0MPC15array5Array4pushGbE(visited, false);
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const parent_edge = new _M0TPB5ArrayGiE([], 0);
  const _bind$4 = 0;
  let _tmp$3 = _bind$4;
  while (true) {
    const _ = _tmp$3;
    if (_ < n) {
      _M0MPC15array5Array4pushGiE(parent_edge, -1);
      _tmp$3 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const parent = new _M0TPB5ArrayGiE([], 0);
  const _bind$5 = 0;
  let _tmp$4 = _bind$5;
  while (true) {
    const _ = _tmp$4;
    if (_ < n) {
      _M0MPC15array5Array4pushGiE(parent, -1);
      _tmp$4 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const children = new _M0TPB5ArrayGRPB5ArrayGiEE([], 0);
  const _bind$6 = 0;
  let _tmp$5 = _bind$6;
  while (true) {
    const _ = _tmp$5;
    if (_ < n) {
      _M0MPC15array5Array4pushGUiiEE(children, new _M0TPB5ArrayGiE([], 0));
      _tmp$5 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const order = new _M0TPB5ArrayGiE([], 0);
  const queue = new _M0TPB5ArrayGiE([], 0);
  _M0MPC15array5Array4pushGiE(queue, root);
  _M0MPC15array5Array3setGbE(visited, root, true);
  const head = new _M0TPB8MutLocalGiE(0);
  while (true) {
    if (head.val < _M0MPC15array5Array6lengthGiE(queue)) {
      const u = _M0MPC15array5Array2atGiE(queue, head.val);
      head.val = head.val + 1 | 0;
      _M0MPC15array5Array4pushGiE(order, u);
      const _bind$7 = _M0MPC15array5Array2atGRPB5ArrayGUiiEEE(adj, u);
      const _bind$8 = _bind$7.len;
      const _bind$9 = _bind$7.buf;
      let _tmp$6 = 0;
      while (true) {
        const _ = _tmp$6;
        if (_ < _bind$8) {
          const pair = _bind$9[_];
          let v;
          let ei;
          _L: {
            const _v = pair._0;
            const _ei = pair._1;
            v = _v;
            ei = _ei;
            break _L;
          }
          if (!_M0MPC15array5Array2atGbE(visited, v)) {
            _M0MPC15array5Array3setGbE(visited, v, true);
            _M0MPC15array5Array3setGiE(parent_edge, v, ei);
            _M0MPC15array5Array3setGiE(parent, v, u);
            _M0MPC15array5Array4pushGiE(_M0MPC15array5Array2atGRPB5ArrayGUiiEEE(children, u), v);
            _M0MPC15array5Array4pushGiE(queue, v);
          }
          _tmp$6 = _ + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      continue;
    } else {
      break;
    }
  }
  if (_M0MPC15array5Array6lengthGiE(order) !== n) {
    const miss = new _M0TPB8MutLocalGiE(0);
    const found = new _M0TPB8MutLocalGbE(false);
    while (true) {
      if (miss.val < n) {
        if (!_M0MPC15array5Array2atGbE(visited, miss.val)) {
          found.val = true;
          break;
        }
        miss.val = miss.val + 1 | 0;
        continue;
      } else {
        break;
      }
    }
    found.val;
    return new _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist8TopologyRP38Duckweed19moon_2dpower_2dflow4dist7TopoErrE3Err(new _M0DTP38Duckweed19moon_2dpower_2dflow4dist7TopoErr12Disconnected(_M0MP38Duckweed19moon_2dpower_2dflow4dist8DistNode2id(_M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet8node__at(net, miss.val))));
  }
  return new _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist8TopologyRP38Duckweed19moon_2dpower_2dflow4dist7TopoErrE2Ok(new _M0TP38Duckweed19moon_2dpower_2dflow4dist8Topology(order, parent_edge, parent, children));
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist8Topology14reverse__order(self) {
  const out = new _M0TPB5ArrayGiE([], 0);
  const i = new _M0TPB8MutLocalGiE(_M0MPC15array5Array6lengthGiE(self.order));
  while (true) {
    if (i.val > 0) {
      i.val = i.val - 1 | 0;
      _M0MPC15array5Array4pushGiE(out, _M0MPC15array5Array2atGiE(self.order, i.val));
      continue;
    } else {
      break;
    }
  }
  return out;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist7SweepOk4iter(self) {
  return self.iter;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist8SweepErr8describe(self) {
  let iter;
  let dv;
  _L: {
    let iter$2;
    _L$2: {
      let e;
      _L$3: {
        switch (self.$tag) {
          case 0: {
            const _Topology = self;
            const _e = _Topology._0;
            e = _e;
            break _L$3;
          }
          case 1: {
            return "topology does not match this network (build_topology on the same net)";
          }
          case 2: {
            const _NonFinite = self;
            const _iter = _NonFinite._0;
            iter$2 = _iter;
            break _L$2;
          }
          case 3: {
            return "invalid config: max_iter must be > 0 and tol must be a positive finite number";
          }
          default: {
            const _NotConverged = self;
            const _iter$2 = _NotConverged._0;
            const _dv = _NotConverged._1;
            iter = _iter$2;
            dv = _dv;
            break _L;
          }
        }
      }
      return `topology: ${_M0MP38Duckweed19moon_2dpower_2dflow4dist7TopoErr8describe(e)}`;
    }
    return `non-finite value at sweep ${_M0MPC13int3Int18to__string_2einner(iter$2, 10)} (NaN in load, impedance or voltage)`;
  }
  return `did not converge after ${_M0MPC13int3Int18to__string_2einner(iter, 10)} sweeps, last max |dV| = ${String(dv)}`;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge2sw(self) {
  return self.sw;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge2tx(self) {
  return self.tx;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge1z(self) {
  return self.z;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet7v__root(self) {
  return self.v_root;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor3add(self, other) {
  return new _M0TP38Duckweed19moon_2dpower_2dflow4dist6Phasor(_M0FP38Duckweed19moon_2dpower_2dflow5model7cx__add(self.a, other.a), _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__add(self.b, other.b), _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__add(self.c, other.c));
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist6Switch1a(self) {
  return self.a;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist6Switch1b(self) {
  return self.b;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist6Switch1c(self) {
  return self.c;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor13apply__switch(self, sw) {
  const zero = _M0FP38Duckweed19moon_2dpower_2dflow5model2cx(0, 0);
  return new _M0TP38Duckweed19moon_2dpower_2dflow4dist6Phasor(_M0MP38Duckweed19moon_2dpower_2dflow4dist6Switch1a(sw) ? self.a : zero, _M0MP38Duckweed19moon_2dpower_2dflow4dist6Switch1b(sw) ? self.b : zero, _M0MP38Duckweed19moon_2dpower_2dflow4dist6Switch1c(sw) ? self.c : zero);
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor8max__abs(self) {
  const a = _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__abs(self.a);
  const b = _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__abs(self.b);
  const c = _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__abs(self.c);
  const m = a > b ? a : b;
  return c > m ? c : m;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor5scale(self, k) {
  return new _M0TP38Duckweed19moon_2dpower_2dflow4dist6Phasor(_M0FP38Duckweed19moon_2dpower_2dflow5model9cx__scale(self.a, k), _M0FP38Duckweed19moon_2dpower_2dflow5model9cx__scale(self.b, k), _M0FP38Duckweed19moon_2dpower_2dflow5model9cx__scale(self.c, k));
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor3sub(self, other) {
  return new _M0TP38Duckweed19moon_2dpower_2dflow4dist6Phasor(_M0FP38Duckweed19moon_2dpower_2dflow5model7cx__sub(self.a, other.a), _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__sub(self.b, other.b), _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__sub(self.c, other.c));
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor4zero() {
  return new _M0TP38Duckweed19moon_2dpower_2dflow4dist6Phasor(_M0FP38Duckweed19moon_2dpower_2dflow5model2cx(0, 0), _M0FP38Duckweed19moon_2dpower_2dflow5model2cx(0, 0), _M0FP38Duckweed19moon_2dpower_2dflow5model2cx(0, 0));
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist6TxSpec7enabled(self) {
  return self.enabled;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist6TxSpec5ratio(self) {
  return self.ratio;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist6TxSpec1z(self) {
  return self.z;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist2Z33mul(self, i) {
  const va = _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__add(_M0FP38Duckweed19moon_2dpower_2dflow5model7cx__add(_M0FP38Duckweed19moon_2dpower_2dflow5model7cx__mul(self.aa, i.a), _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__mul(self.ab, i.b)), _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__mul(self.ac, i.c));
  const vb = _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__add(_M0FP38Duckweed19moon_2dpower_2dflow5model7cx__add(_M0FP38Duckweed19moon_2dpower_2dflow5model7cx__mul(self.ab, i.a), _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__mul(self.bb, i.b)), _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__mul(self.bc, i.c));
  const vc = _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__add(_M0FP38Duckweed19moon_2dpower_2dflow5model7cx__add(_M0FP38Duckweed19moon_2dpower_2dflow5model7cx__mul(self.ac, i.a), _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__mul(self.bc, i.b)), _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__mul(self.cc, i.c));
  return new _M0TP38Duckweed19moon_2dpower_2dflow4dist6Phasor(va, vb, vc);
}
function _M0FP38Duckweed19moon_2dpower_2dflow4dist16sweep__with__zip(net, topo, zip, tol, max_iter) {
  const n = _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet11node__count(net);
  const m = _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet11edge__count(net);
  if (max_iter <= 0) {
    return new _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist7SweepOkRP38Duckweed19moon_2dpower_2dflow4dist8SweepErrE3Err(_M0DTP38Duckweed19moon_2dpower_2dflow4dist8SweepErr13InvalidConfig__);
  }
  if (!(tol > 0) || tol > 1e+308) {
    return new _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist7SweepOkRP38Duckweed19moon_2dpower_2dflow4dist8SweepErrE3Err(_M0DTP38Duckweed19moon_2dpower_2dflow4dist8SweepErr13InvalidConfig__);
  }
  if (_M0MPC15array5Array6lengthGiE(_M0MP38Duckweed19moon_2dpower_2dflow4dist8Topology12parent__edge(topo)) !== n || _M0MPC15array5Array6lengthGiE(_M0MP38Duckweed19moon_2dpower_2dflow4dist8Topology6parent(topo)) !== n) {
    return new _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist7SweepOkRP38Duckweed19moon_2dpower_2dflow4dist8SweepErrE3Err(_M0DTP38Duckweed19moon_2dpower_2dflow4dist8SweepErr16TopologyMismatch__);
  }
  let root;
  const _bind = _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet11find__index(net, _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet8root__id(net));
  if (_bind === undefined) {
    return new _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist7SweepOkRP38Duckweed19moon_2dpower_2dflow4dist8SweepErrE3Err(new _M0DTP38Duckweed19moon_2dpower_2dflow4dist8SweepErr8Topology(_M0DTP38Duckweed19moon_2dpower_2dflow4dist7TopoErr12RootNotFound__));
  } else {
    const _Some = _bind;
    const _k = _Some;
    root = _k;
  }
  const _bind$2 = 0;
  let _tmp = _bind$2;
  while (true) {
    const u = _tmp;
    if (u < n) {
      const pe = _M0MPC15array5Array2atGiE(_M0MP38Duckweed19moon_2dpower_2dflow4dist8Topology12parent__edge(topo), u);
      if (pe === -1) {
        if (u !== root) {
          return new _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist7SweepOkRP38Duckweed19moon_2dpower_2dflow4dist8SweepErrE3Err(_M0DTP38Duckweed19moon_2dpower_2dflow4dist8SweepErr16TopologyMismatch__);
        }
      } else {
        if (pe < 0 || pe >= m) {
          return new _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist7SweepOkRP38Duckweed19moon_2dpower_2dflow4dist8SweepErrE3Err(_M0DTP38Duckweed19moon_2dpower_2dflow4dist8SweepErr16TopologyMismatch__);
        } else {
          const pu = _M0MPC15array5Array2atGiE(_M0MP38Duckweed19moon_2dpower_2dflow4dist8Topology6parent(topo), u);
          if (pu < 0 || pu >= n) {
            return new _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist7SweepOkRP38Duckweed19moon_2dpower_2dflow4dist8SweepErrE3Err(_M0DTP38Duckweed19moon_2dpower_2dflow4dist8SweepErr16TopologyMismatch__);
          }
          const e = _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet8edge__at(net, pe);
          const uid = _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistNode2id(_M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet8node__at(net, u));
          const pid = _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistNode2id(_M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet8node__at(net, pu));
          const connected = _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge8from__id(e) === pid && _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge6to__id(e) === uid || _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge8from__id(e) === uid && _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge6to__id(e) === pid;
          if (!connected) {
            return new _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist7SweepOkRP38Duckweed19moon_2dpower_2dflow4dist8SweepErrE3Err(_M0DTP38Duckweed19moon_2dpower_2dflow4dist8SweepErr16TopologyMismatch__);
          }
        }
      }
      _tmp = u + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const v_root = _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet7v__root(net);
  const v = new _M0TPB5ArrayGRP38Duckweed19moon_2dpower_2dflow4dist6PhasorE([], 0);
  const _bind$3 = 0;
  let _tmp$2 = _bind$3;
  while (true) {
    const _ = _tmp$2;
    if (_ < n) {
      _M0MPC15array5Array4pushGUiiEE(v, v_root);
      _tmp$2 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const i_branch = new _M0TPB5ArrayGRP38Duckweed19moon_2dpower_2dflow4dist6PhasorE([], 0);
  const _bind$4 = 0;
  let _tmp$3 = _bind$4;
  while (true) {
    const _ = _tmp$3;
    if (_ < m) {
      _M0MPC15array5Array4pushGUiiEE(i_branch, _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor4zero());
      _tmp$3 = _ + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  const order = _M0MP38Duckweed19moon_2dpower_2dflow4dist8Topology5order(topo);
  const rev = _M0MP38Duckweed19moon_2dpower_2dflow4dist8Topology14reverse__order(topo);
  const parent_edge = _M0MP38Duckweed19moon_2dpower_2dflow4dist8Topology12parent__edge(topo);
  const parent = _M0MP38Duckweed19moon_2dpower_2dflow4dist8Topology6parent(topo);
  const children = _M0MP38Duckweed19moon_2dpower_2dflow4dist8Topology8children(topo);
  const iter = new _M0TPB8MutLocalGiE(0);
  const last_dv = new _M0TPB8MutLocalGdE(1);
  const trace = new _M0TPB5ArrayGdE([], 0);
  while (true) {
    if (iter.val < max_iter) {
      iter.val = iter.val + 1 | 0;
      const _bind$5 = rev.len;
      const _bind$6 = rev.buf;
      let _tmp$4 = 0;
      while (true) {
        const _ = _tmp$4;
        if (_ < _bind$5) {
          const u = _bind$6[_];
          if (u !== root) {
            const i_load = _M0FP38Duckweed19moon_2dpower_2dflow4dist13load__current(_M0MP38Duckweed19moon_2dpower_2dflow4dist8DistNode1s(_M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet8node__at(net, u)), _M0MPC15array5Array2atGRPB5ArrayGUiiEEE(v, u), zip);
            const total = new _M0TPB8MutLocalGRP38Duckweed19moon_2dpower_2dflow4dist6PhasorE(i_load);
            const _bind$7 = _M0MPC15array5Array2atGRPB5ArrayGUiiEEE(children, u);
            const _bind$8 = _bind$7.len;
            const _bind$9 = _bind$7.buf;
            let _tmp$5 = 0;
            while (true) {
              const _$2 = _tmp$5;
              if (_$2 < _bind$8) {
                const ch = _bind$9[_$2];
                const ce = _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet8edge__at(net, _M0MPC15array5Array2atGiE(parent_edge, ch));
                const i_ch = _M0MPC15array5Array2atGRPB5ArrayGUiiEEE(i_branch, _M0MPC15array5Array2atGiE(parent_edge, ch));
                total.val = _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor3add(total.val, _M0MP38Duckweed19moon_2dpower_2dflow4dist6TxSpec7enabled(_M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge2tx(ce)) ? _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor5scale(i_ch, _M0MP38Duckweed19moon_2dpower_2dflow4dist6TxSpec5ratio(_M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge2tx(ce))) : i_ch);
                _tmp$5 = _$2 + 1 | 0;
                continue;
              } else {
                break;
              }
            }
            const pe = _M0MPC15array5Array2atGiE(parent_edge, u);
            total.val = _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor13apply__switch(total.val, _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge2sw(_M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet8edge__at(net, pe)));
            _M0MPC15array5Array3setGRP38Duckweed19moon_2dpower_2dflow4dist6PhasorE(i_branch, pe, total.val);
          }
          _tmp$4 = _ + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      const max_dv = new _M0TPB8MutLocalGdE(0);
      const seen_nan = new _M0TPB8MutLocalGbE(false);
      const _bind$7 = order.len;
      const _bind$8 = order.buf;
      let _tmp$5 = 0;
      while (true) {
        const _ = _tmp$5;
        if (_ < _bind$7) {
          const u = _bind$8[_];
          if (u !== root) {
            const pe = _M0MPC15array5Array2atGiE(parent_edge, u);
            const e = _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet8edge__at(net, pe);
            const tx = _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge2tx(e);
            let z;
            let base;
            _L: {
              if (_M0MP38Duckweed19moon_2dpower_2dflow4dist6TxSpec7enabled(tx)) {
                z = _M0MP38Duckweed19moon_2dpower_2dflow4dist6TxSpec1z(tx);
                base = _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor5scale(_M0MPC15array5Array2atGRPB5ArrayGUiiEEE(v, _M0MPC15array5Array2atGiE(parent, u)), _M0MP38Duckweed19moon_2dpower_2dflow4dist6TxSpec5ratio(tx));
                break _L;
              } else {
                z = _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge1z(e);
                base = _M0MPC15array5Array2atGRPB5ArrayGUiiEEE(v, _M0MPC15array5Array2atGiE(parent, u));
                break _L;
              }
            }
            const drop = _M0MP38Duckweed19moon_2dpower_2dflow4dist2Z33mul(z, _M0MPC15array5Array2atGRPB5ArrayGUiiEEE(i_branch, pe));
            const v_new = _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor13apply__switch(_M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor3sub(base, drop), _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge2sw(e));
            const dv = _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor8max__abs(_M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor3sub(v_new, _M0MPC15array5Array2atGRPB5ArrayGUiiEEE(v, u)));
            if (dv !== dv) {
              seen_nan.val = true;
            }
            if (dv > max_dv.val) {
              max_dv.val = dv;
            }
            _M0MPC15array5Array3setGRP38Duckweed19moon_2dpower_2dflow4dist6PhasorE(v, u, v_new);
          }
          _tmp$5 = _ + 1 | 0;
          continue;
        } else {
          break;
        }
      }
      if (seen_nan.val) {
        return new _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist7SweepOkRP38Duckweed19moon_2dpower_2dflow4dist8SweepErrE3Err(new _M0DTP38Duckweed19moon_2dpower_2dflow4dist8SweepErr9NonFinite(iter.val));
      }
      last_dv.val = max_dv.val;
      _M0MPC15array5Array4pushGdE(trace, max_dv.val);
      if (max_dv.val < tol) {
        return new _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist7SweepOkRP38Duckweed19moon_2dpower_2dflow4dist8SweepErrE2Ok(new _M0TP38Duckweed19moon_2dpower_2dflow4dist7SweepOk(iter.val, v, i_branch, max_dv.val, trace));
      }
      continue;
    } else {
      break;
    }
  }
  return new _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist7SweepOkRP38Duckweed19moon_2dpower_2dflow4dist8SweepErrE3Err(new _M0DTP38Duckweed19moon_2dpower_2dflow4dist8SweepErr12NotConverged(max_iter, last_dv.val));
}
function _M0FP38Duckweed19moon_2dpower_2dflow4dist5sweep(net, topo, tol, max_iter) {
  return _M0FP38Duckweed19moon_2dpower_2dflow4dist16sweep__with__zip(net, topo, undefined, tol, max_iter);
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge11with__ratio(self, ratio) {
  const tx = new _M0TP38Duckweed19moon_2dpower_2dflow4dist6TxSpec(ratio, _M0MP38Duckweed19moon_2dpower_2dflow4dist6TxSpec1z(self.tx), true);
  return new _M0TP38Duckweed19moon_2dpower_2dflow4dist8DistEdge(self.from_id, self.to_id, self.z, tx, self.sw);
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet4make(nodes, edges, root_id, v_root) {
  return new _M0TP38Duckweed19moon_2dpower_2dflow4dist7DistNet(nodes, edges, root_id, v_root);
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet5nodes(self) {
  return self.nodes;
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor7uniform(v) {
  return new _M0TP38Duckweed19moon_2dpower_2dflow4dist6Phasor(v, v, v);
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor8balanced(mag, angle) {
  const pi = 3.1415926535897931;
  return new _M0TP38Duckweed19moon_2dpower_2dflow4dist6Phasor(_M0FP38Duckweed19moon_2dpower_2dflow5model9cx__polar(mag, angle), _M0FP38Duckweed19moon_2dpower_2dflow5model9cx__polar(mag, angle - 2 * pi / 3), _M0FP38Duckweed19moon_2dpower_2dflow5model9cx__polar(mag, angle + 2 * pi / 3));
}
function _M0FP38Duckweed19moon_2dpower_2dflow4dist8z3__diag(za, zb, zc) {
  const zero = _M0FP38Duckweed19moon_2dpower_2dflow5model2cx(0, 0);
  return new _M0TP38Duckweed19moon_2dpower_2dflow4dist2Z3(za, zb, zc, zero, zero, zero);
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistNode4make(id, s) {
  return new _M0TP38Duckweed19moon_2dpower_2dflow4dist8DistNode(id, s);
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist6TxSpec8disabled() {
  const zero = _M0FP38Duckweed19moon_2dpower_2dflow5model2cx(0, 0);
  return new _M0TP38Duckweed19moon_2dpower_2dflow4dist6TxSpec(1, _M0FP38Duckweed19moon_2dpower_2dflow4dist8z3__diag(zero, zero, zero), false);
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist6TxSpec3new(ratio, z) {
  if (ratio !== ratio || (ratio <= 0 || ratio > 1e+308)) {
    return new _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist6TxSpecsE3Err("transformer ratio must be a positive finite number");
  }
  const all_zero = z.aa.re === 0 && (z.aa.im === 0 && (z.bb.re === 0 && (z.bb.im === 0 && (z.cc.re === 0 && z.cc.im === 0))));
  if (all_zero) {
    return new _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist6TxSpecsE3Err("transformer leakage impedance must not be all zero");
  }
  return new _M0DTPB6ResultGRP38Duckweed19moon_2dpower_2dflow4dist6TxSpecsE2Ok(new _M0TP38Duckweed19moon_2dpower_2dflow4dist6TxSpec(ratio, z, true));
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist6Switch6closed() {
  return new _M0TP38Duckweed19moon_2dpower_2dflow4dist6Switch(true, true, true);
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist6Switch11open__phase(self, phase) {
  switch (phase) {
    case 0: {
      return new _M0TP38Duckweed19moon_2dpower_2dflow4dist6Switch(false, self.b, self.c);
    }
    case 1: {
      return new _M0TP38Duckweed19moon_2dpower_2dflow4dist6Switch(self.a, false, self.c);
    }
    default: {
      return new _M0TP38Duckweed19moon_2dpower_2dflow4dist6Switch(self.a, self.b, false);
    }
  }
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge4make(from_id, to_id, z) {
  return new _M0TP38Duckweed19moon_2dpower_2dflow4dist8DistEdge(from_id, to_id, z, _M0MP38Duckweed19moon_2dpower_2dflow4dist6TxSpec8disabled(), _M0MP38Duckweed19moon_2dpower_2dflow4dist6Switch6closed());
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge8make__tx(from_id, to_id, tx) {
  const zero = _M0FP38Duckweed19moon_2dpower_2dflow5model2cx(0, 0);
  return new _M0TP38Duckweed19moon_2dpower_2dflow4dist8DistEdge(from_id, to_id, _M0FP38Duckweed19moon_2dpower_2dflow4dist8z3__diag(zero, zero, zero), tx, _M0MP38Duckweed19moon_2dpower_2dflow4dist6Switch6closed());
}
function _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge12with__switch(self, sw) {
  return new _M0TP38Duckweed19moon_2dpower_2dflow4dist8DistEdge(self.from_id, self.to_id, self.z, self.tx, sw);
}
function _M0FP38Duckweed19moon_2dpower_2dflow4dist16case__four__node() {
  const z = _M0FP38Duckweed19moon_2dpower_2dflow5model2cx(0.01, 0.02);
  const z12 = _M0FP38Duckweed19moon_2dpower_2dflow4dist8z3__diag(z, z, z);
  const z23 = _M0FP38Duckweed19moon_2dpower_2dflow4dist8z3__diag(z, z, z);
  const z24 = _M0FP38Duckweed19moon_2dpower_2dflow4dist8z3__diag(z, z, z);
  const nodes = new _M0TPB5ArrayGRP38Duckweed19moon_2dpower_2dflow4dist8DistNodeE([_M0MP38Duckweed19moon_2dpower_2dflow4dist8DistNode4make(1, _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor4zero()), _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistNode4make(2, _M0FP38Duckweed19moon_2dpower_2dflow4dist6phasor(_M0FP38Duckweed19moon_2dpower_2dflow5model2cx(0.1, 0.03), _M0FP38Duckweed19moon_2dpower_2dflow5model2cx(0.05, 0.02), _M0FP38Duckweed19moon_2dpower_2dflow5model2cx(0.03, 0.01))), _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistNode4make(3, _M0FP38Duckweed19moon_2dpower_2dflow4dist6phasor(_M0FP38Duckweed19moon_2dpower_2dflow5model2cx(0.06, 0.02), _M0FP38Duckweed19moon_2dpower_2dflow5model2cx(0, 0), _M0FP38Duckweed19moon_2dpower_2dflow5model2cx(0.02, 0.005))), _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistNode4make(4, _M0FP38Duckweed19moon_2dpower_2dflow4dist6phasor(_M0FP38Duckweed19moon_2dpower_2dflow5model2cx(0, 0), _M0FP38Duckweed19moon_2dpower_2dflow5model2cx(0, 0), _M0FP38Duckweed19moon_2dpower_2dflow5model2cx(0.04, 0.015)))], 4);
  const edges = new _M0TPB5ArrayGRP38Duckweed19moon_2dpower_2dflow4dist8DistEdgeE([_M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge4make(1, 2, z12), _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge4make(2, 3, z23), _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge4make(2, 4, z24)], 3);
  return _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet4make(nodes, edges, 1, _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor8balanced(1, 0));
}
function _M0FP38Duckweed19moon_2dpower_2dflow4dist23case__with__transformer() {
  const zt = _M0FP38Duckweed19moon_2dpower_2dflow5model2cx(0.02, 0.04);
  const z3 = _M0FP38Duckweed19moon_2dpower_2dflow4dist8z3__diag(zt, zt, zt);
  let tx;
  const _bind = _M0MP38Duckweed19moon_2dpower_2dflow4dist6TxSpec3new(1, z3);
  if (_bind.$tag === 1) {
    const _Ok = _bind;
    const _t = _Ok._0;
    tx = _t;
  } else {
    tx = _M0MP38Duckweed19moon_2dpower_2dflow4dist6TxSpec8disabled();
  }
  const s = _M0FP38Duckweed19moon_2dpower_2dflow5model2cx(0.1, 0.03);
  const nodes = new _M0TPB5ArrayGRP38Duckweed19moon_2dpower_2dflow4dist8DistNodeE([_M0MP38Duckweed19moon_2dpower_2dflow4dist8DistNode4make(1, _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor4zero()), _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistNode4make(2, _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor7uniform(s))], 2);
  const edges = new _M0TPB5ArrayGRP38Duckweed19moon_2dpower_2dflow4dist8DistEdgeE([_M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge8make__tx(1, 2, tx)], 1);
  return _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet4make(nodes, edges, 1, _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor8balanced(1, 0));
}
function _M0FP38Duckweed19moon_2dpower_2dflow4dist23case__with__open__phase() {
  const z = _M0FP38Duckweed19moon_2dpower_2dflow5model2cx(0.01, 0.02);
  const z3 = _M0FP38Duckweed19moon_2dpower_2dflow4dist8z3__diag(z, z, z);
  const s = _M0FP38Duckweed19moon_2dpower_2dflow4dist6phasor(_M0FP38Duckweed19moon_2dpower_2dflow5model2cx(0.08, 0.02), _M0FP38Duckweed19moon_2dpower_2dflow5model2cx(0.06, 0.02), _M0FP38Duckweed19moon_2dpower_2dflow5model2cx(0.08, 0.02));
  const nodes = new _M0TPB5ArrayGRP38Duckweed19moon_2dpower_2dflow4dist8DistNodeE([_M0MP38Duckweed19moon_2dpower_2dflow4dist8DistNode4make(1, _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor4zero()), _M0MP38Duckweed19moon_2dpower_2dflow4dist8DistNode4make(2, s)], 2);
  const closed = _M0MP38Duckweed19moon_2dpower_2dflow4dist6Switch11open__phase(_M0MP38Duckweed19moon_2dpower_2dflow4dist6Switch6closed(), 1);
  const edges = new _M0TPB5ArrayGRP38Duckweed19moon_2dpower_2dflow4dist8DistEdgeE([_M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge12with__switch(_M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge4make(1, 2, z3), closed)], 1);
  return _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet4make(nodes, edges, 1, _M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor8balanced(1, 0));
}
function _M0FP48Duckweed19moon_2dpower_2dflow8examples9web__demo4jnum(x) {
  const q = _M0MPC16double6Double5round(x * 10000);
  const v = q / 10000;
  return v === 0 ? "0" : String(v);
}
function _M0FP48Duckweed19moon_2dpower_2dflow8examples9web__demo4jarr(xs) {
  const s = new _M0TPB8MutLocalGsE("[");
  const i = new _M0TPB8MutLocalGiE(0);
  while (true) {
    if (i.val < _M0MPC15array5Array6lengthGdE(xs)) {
      if (i.val > 0) {
        s.val = `${s.val},`;
      }
      s.val = `${s.val}${_M0FP48Duckweed19moon_2dpower_2dflow8examples9web__demo4jnum(_M0MPC15array5Array2atGdE(xs, i.val))}`;
      i.val = i.val + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return `${s.val}]`;
}
function _M0FP48Duckweed19moon_2dpower_2dflow8examples9web__demo14phase__columns(r) {
  const vs = _M0MP38Duckweed19moon_2dpower_2dflow4dist7SweepOk8voltages(r);
  const va = new _M0TPB5ArrayGdE([], 0);
  const vb = new _M0TPB5ArrayGdE([], 0);
  const vc = new _M0TPB5ArrayGdE([], 0);
  const vuf = new _M0TPB5ArrayGdE([], 0);
  const i = new _M0TPB8MutLocalGiE(0);
  while (true) {
    if (i.val < _M0MPC15array5Array6lengthGRP38Duckweed19moon_2dpower_2dflow4dist6PhasorE(vs)) {
      _M0MPC15array5Array4pushGdE(va, _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__abs(_M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor1a(_M0MPC15array5Array2atGRPB5ArrayGUiiEEE(vs, i.val))));
      _M0MPC15array5Array4pushGdE(vb, _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__abs(_M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor1b(_M0MPC15array5Array2atGRPB5ArrayGUiiEEE(vs, i.val))));
      _M0MPC15array5Array4pushGdE(vc, _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__abs(_M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor1c(_M0MPC15array5Array2atGRPB5ArrayGUiiEEE(vs, i.val))));
      _M0MPC15array5Array4pushGdE(vuf, _M0FP38Duckweed19moon_2dpower_2dflow4dist27voltage__unbalance__percent(_M0MPC15array5Array2atGRPB5ArrayGUiiEEE(vs, i.val)));
      i.val = i.val + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return { _0: _M0FP48Duckweed19moon_2dpower_2dflow8examples9web__demo4jarr(va), _1: _M0FP48Duckweed19moon_2dpower_2dflow8examples9web__demo4jarr(vb), _2: _M0FP48Duckweed19moon_2dpower_2dflow8examples9web__demo4jarr(vc), _3: _M0FP48Duckweed19moon_2dpower_2dflow8examples9web__demo4jarr(vuf), _4: _M0MP38Duckweed19moon_2dpower_2dflow4dist7SweepOk4iter(r) };
}
function _M0FP48Duckweed19moon_2dpower_2dflow8examples9web__demo11panel__four() {
  const net = _M0FP38Duckweed19moon_2dpower_2dflow4dist16case__four__node();
  let topo;
  _L: {
    let e;
    _L$2: {
      const _bind = _M0FP38Duckweed19moon_2dpower_2dflow4dist15build__topology(net);
      if (_bind.$tag === 0) {
        const _Err = _bind;
        const _e = _Err._0;
        e = _e;
        break _L$2;
      } else {
        const _Ok = _bind;
        const _topo = _Ok._0;
        topo = _topo;
        break _L;
      }
    }
    return `ERR ${_M0MP38Duckweed19moon_2dpower_2dflow4dist7TopoErr8describe(e)}`;
  }
  let r;
  _L$2: {
    let e;
    _L$3: {
      const _bind = _M0FP38Duckweed19moon_2dpower_2dflow4dist5sweep(net, topo, 1e-009, 100);
      if (_bind.$tag === 0) {
        const _Err = _bind;
        const _e = _Err._0;
        e = _e;
        break _L$3;
      } else {
        const _Ok = _bind;
        const _r = _Ok._0;
        r = _r;
        break _L$2;
      }
    }
    return `ERR ${_M0MP38Duckweed19moon_2dpower_2dflow4dist8SweepErr8describe(e)}`;
  }
  let vuf;
  let vb;
  let va;
  let vc;
  let iter;
  _L$3: {
    const _bind = _M0FP48Duckweed19moon_2dpower_2dflow8examples9web__demo14phase__columns(r);
    const _va = _bind._0;
    const _vb = _bind._1;
    const _vc = _bind._2;
    const _vuf = _bind._3;
    const _iter = _bind._4;
    vuf = _vuf;
    vb = _vb;
    va = _va;
    vc = _vc;
    iter = _iter;
    break _L$3;
  }
  return `DATA {\"panel\":\"four\",\"va\":${va},\"vb\":${vb},\"vc\":${vc},\"vuf\":${vuf},\"iter\":${_M0MPC13int3Int18to__string_2einner(iter, 10)}}`;
}
function _M0FP48Duckweed19moon_2dpower_2dflow8examples9web__demo11panel__open() {
  const net = _M0FP38Duckweed19moon_2dpower_2dflow4dist23case__with__open__phase();
  let topo;
  _L: {
    let e;
    _L$2: {
      const _bind = _M0FP38Duckweed19moon_2dpower_2dflow4dist15build__topology(net);
      if (_bind.$tag === 0) {
        const _Err = _bind;
        const _e = _Err._0;
        e = _e;
        break _L$2;
      } else {
        const _Ok = _bind;
        const _topo = _Ok._0;
        topo = _topo;
        break _L;
      }
    }
    return `ERR ${_M0MP38Duckweed19moon_2dpower_2dflow4dist7TopoErr8describe(e)}`;
  }
  let r;
  _L$2: {
    let e;
    _L$3: {
      const _bind = _M0FP38Duckweed19moon_2dpower_2dflow4dist5sweep(net, topo, 1e-009, 100);
      if (_bind.$tag === 0) {
        const _Err = _bind;
        const _e = _Err._0;
        e = _e;
        break _L$3;
      } else {
        const _Ok = _bind;
        const _r = _Ok._0;
        r = _r;
        break _L$2;
      }
    }
    return `ERR ${_M0MP38Duckweed19moon_2dpower_2dflow4dist8SweepErr8describe(e)}`;
  }
  let vuf;
  let vb;
  let va;
  let vc;
  let iter;
  _L$3: {
    const _bind = _M0FP48Duckweed19moon_2dpower_2dflow8examples9web__demo14phase__columns(r);
    const _va = _bind._0;
    const _vb = _bind._1;
    const _vc = _bind._2;
    const _vuf = _bind._3;
    const _iter = _bind._4;
    vuf = _vuf;
    vb = _vb;
    va = _va;
    vc = _vc;
    iter = _iter;
    break _L$3;
  }
  return `DATA {\"panel\":\"open\",\"va\":${va},\"vb\":${vb},\"vc\":${vc},\"vuf\":${vuf},\"iter\":${_M0MPC13int3Int18to__string_2einner(iter, 10)}}`;
}
function _M0FP48Duckweed19moon_2dpower_2dflow8examples9web__demo10panel__tap() {
  const base = _M0FP38Duckweed19moon_2dpower_2dflow4dist23case__with__transformer();
  let topo;
  let e;
  _L: {
    _L$2: {
      const _bind = _M0FP38Duckweed19moon_2dpower_2dflow4dist15build__topology(base);
      if (_bind.$tag === 0) {
        const _Err = _bind;
        const _e = _Err._0;
        e = _e;
        break _L$2;
      } else {
        const _Ok = _bind;
        const _t = _Ok._0;
        topo = _t;
      }
      break _L;
    }
    return `ERR ${_M0MP38Duckweed19moon_2dpower_2dflow4dist7TopoErr8describe(e)}`;
  }
  const tap = new _M0TPB5ArrayGdE([], 0);
  const ratio = new _M0TPB5ArrayGdE([], 0);
  const v2 = new _M0TPB5ArrayGdE([], 0);
  const iter = new _M0TPB5ArrayGdE([], 0);
  const t = new _M0TPB8MutLocalGiE(-4);
  while (true) {
    if (t.val <= 4) {
      const k = 1 + (t.val + 0) * 0.0125;
      const edges = new _M0TPB5ArrayGRP38Duckweed19moon_2dpower_2dflow4dist8DistEdgeE([_M0MP38Duckweed19moon_2dpower_2dflow4dist8DistEdge11with__ratio(_M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet8edge__at(base, 0), k)], 1);
      const net = _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet4make(_M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet5nodes(base), edges, _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet8root__id(base), _M0MP38Duckweed19moon_2dpower_2dflow4dist7DistNet7v__root(base));
      let r;
      _L$2: {
        let e$2;
        _L$3: {
          const _bind = _M0FP38Duckweed19moon_2dpower_2dflow4dist5sweep(net, topo, 1e-009, 100);
          if (_bind.$tag === 0) {
            const _Err = _bind;
            const _e = _Err._0;
            e$2 = _e;
            break _L$3;
          } else {
            const _Ok = _bind;
            const _r = _Ok._0;
            r = _r;
            break _L$2;
          }
        }
        return `ERR ${_M0MP38Duckweed19moon_2dpower_2dflow4dist8SweepErr8describe(e$2)}`;
      }
      _M0MPC15array5Array4pushGdE(tap, t.val + 0);
      _M0MPC15array5Array4pushGdE(ratio, k);
      _M0MPC15array5Array4pushGdE(v2, _M0FP38Duckweed19moon_2dpower_2dflow5model7cx__abs(_M0MP38Duckweed19moon_2dpower_2dflow4dist6Phasor1a(_M0MPC15array5Array2atGRPB5ArrayGUiiEEE(_M0MP38Duckweed19moon_2dpower_2dflow4dist7SweepOk8voltages(r), 1))));
      _M0MPC15array5Array4pushGdE(iter, _M0MP38Duckweed19moon_2dpower_2dflow4dist7SweepOk4iter(r) + 0);
      t.val = t.val + 1 | 0;
      continue;
    } else {
      break;
    }
  }
  return `DATA {\"panel\":\"tap\",\"tap\":${_M0FP48Duckweed19moon_2dpower_2dflow8examples9web__demo4jarr(tap)},\"ratio\":${_M0FP48Duckweed19moon_2dpower_2dflow8examples9web__demo4jarr(ratio)},\"v2\":${_M0FP48Duckweed19moon_2dpower_2dflow8examples9web__demo4jarr(v2)},\"iter\":${_M0FP48Duckweed19moon_2dpower_2dflow8examples9web__demo4jarr(iter)}}`;
}
(() => {
  _M0FPB7printlnGsE("META {\"tol\":0.000000001,\"max_iter\":100}");
  _M0FPB7printlnGsE(_M0FP48Duckweed19moon_2dpower_2dflow8examples9web__demo11panel__four());
  _M0FPB7printlnGsE(_M0FP48Duckweed19moon_2dpower_2dflow8examples9web__demo11panel__open());
  _M0FPB7printlnGsE(_M0FP48Duckweed19moon_2dpower_2dflow8examples9web__demo10panel__tap());
})();
//# sourceMappingURL=web_demo.js.map
