// Compiles a dart2wasm-generated main module from `source` which can then
// instantiatable via the `instantiate` method.
//
// `source` needs to be a `Response` object (or promise thereof) e.g. created
// via the `fetch()` JS API.
export async function compileStreaming(source) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(
      await WebAssembly.compileStreaming(source, builtins), builtins);
}

// Compiles a dart2wasm-generated wasm modules from `bytes` which is then
// instantiatable via the `instantiate` method.
export async function compile(bytes) {
  const builtins = {builtins: ['js-string']};
  return new CompiledApp(await WebAssembly.compile(bytes, builtins), builtins);
}

// DEPRECATED: Please use `compile` or `compileStreaming` to get a compiled app,
// use `instantiate` method to get an instantiated app and then call
// `invokeMain` to invoke the main function.
export async function instantiate(modulePromise, importObjectPromise) {
  var moduleOrCompiledApp = await modulePromise;
  if (!(moduleOrCompiledApp instanceof CompiledApp)) {
    moduleOrCompiledApp = new CompiledApp(moduleOrCompiledApp);
  }
  const instantiatedApp = await moduleOrCompiledApp.instantiate(await importObjectPromise);
  return instantiatedApp.instantiatedModule;
}

// DEPRECATED: Please use `compile` or `compileStreaming` to get a compiled app,
// use `instantiate` method to get an instantiated app and then call
// `invokeMain` to invoke the main function.
export const invoke = (moduleInstance, ...args) => {
  moduleInstance.exports.$invokeMain(args);
}

class CompiledApp {
  constructor(module, builtins) {
    this.module = module;
    this.builtins = builtins;
  }

  // The second argument is an options object containing:
  // `loadDeferredModules` is a JS function that takes an array of module names
  //   matching wasm files produced by the dart2wasm compiler. It also takes a
  //   callback that should be invoked for each loaded module with 2 arugments:
  //   (1) the module name, (2) the loaded module in a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`. The callback
  //   returns a Promise that resolves when the module is instantiated.
  //   loadDeferredModules should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  // `loadDeferredId` is a JS function that takes load ID produced by the
  //   compiler when the `load-ids` option is passed. Each load ID maps to one
  //   or more wasm files as specified in the emitted JSON file. It also takes a
  //   callback that should be invoked for each loaded module with 2 arugments:
  //   (1) the module name, (2) the loaded module in a format supported by
  //   `WebAssembly.compile` or `WebAssembly.compileStreaming`. The callback
  //   returns a Promise that resolves when the module is instantiated.
  //   loadDeferredModules should return a Promise that resolves when all the
  //   modules have been loaded and the callback promises have resolved.
  // `loadDynamicModule` is a JS function that takes two string names matching,
  //   in order, a wasm file produced by the dart2wasm compiler during dynamic
  //   module compilation and a corresponding js file produced by the same
  //   compilation. It also takes a callback that should be invoked with the
  //   loaded module in a format supported by `WebAssembly.compile` or
  //   `WebAssembly.compileStreaming` and the result of using the JS 'import'
  //   API on the js file path. It should return a Promise that resolves when
  //   all the modules have been loaded and the callback promises have resolved.
  async instantiate(additionalImports,
      {loadDeferredModules, loadDynamicModule, loadDeferredId} = {}) {
    let dartInstance;

    // Prints to the console
    function printToConsole(value) {
      if (typeof dartPrint == "function") {
        dartPrint(value);
        return;
      }
      if (typeof console == "object" && typeof console.log != "undefined") {
        console.log(value);
        return;
      }
      if (typeof print == "function") {
        print(value);
        return;
      }

      throw "Unable to print message: " + value;
    }

    // A special symbol attached to functions that wrap Dart functions.
    const jsWrappedDartFunctionSymbol = Symbol("JSWrappedDartFunction");

    function finalizeWrapper(dartFunction, wrapped) {
      wrapped.dartFunction = dartFunction;
      wrapped[jsWrappedDartFunctionSymbol] = true;
      return wrapped;
    }

    // Imports
    const dart2wasm = {
            _1: (decoder, codeUnits) => decoder.decode(codeUnits),
      _2: () => new TextDecoder("utf-8", {fatal: true}),
      _3: () => new TextDecoder("utf-8", {fatal: false}),
      _4: (s) => +s,
      _5: x0 => new Uint8Array(x0),
      _6: (x0,x1,x2) => x0.set(x1,x2),
      _7: (x0,x1) => x0.transferFromImageBitmap(x1),
      _9: (x0,x1,x2) => x0.slice(x1,x2),
      _10: (x0,x1) => x0.decode(x1),
      _11: (x0,x1) => x0.segment(x1),
      _12: () => new TextDecoder(),
      _14: x0 => x0.buffer,
      _15: x0 => x0.wasmMemory,
      _16: () => globalThis.window._flutter_skwasmInstance,
      _17: x0 => x0.rasterStartMilliseconds,
      _18: x0 => x0.rasterEndMilliseconds,
      _19: x0 => x0.imageBitmaps,
      _135: (x0,x1) => x0.appendChild(x1),
      _166: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _167: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _168: (x0,x1) => new OffscreenCanvas(x0,x1),
      _169: x0 => x0.remove(),
      _170: (x0,x1) => x0.append(x1),
      _172: x0 => x0.unlock(),
      _173: x0 => x0.getReader(),
      _174: (x0,x1) => x0.item(x1),
      _175: x0 => x0.next(),
      _176: x0 => x0.now(),
      _183: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._183(f,arguments.length,x0) }),
      _184: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _186: (x0,x1) => x0.getModifierState(x1),
      _187: x0 => x0.preventDefault(),
      _188: x0 => x0.stopPropagation(),
      _189: (x0,x1) => x0.removeProperty(x1),
      _190: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._190(f,arguments.length,x0) }),
      _191: x0 => new window.FinalizationRegistry(x0),
      _192: (x0,x1,x2,x3) => x0.register(x1,x2,x3),
      _194: (x0,x1) => x0.unregister(x1),
      _195: (x0,x1) => x0.prepend(x1),
      _196: x0 => new Intl.Locale(x0),
      _197: (x0,x1) => x0.observe(x1),
      _198: x0 => x0.disconnect(),
      _199: (x0,x1) => x0.getAttribute(x1),
      _200: (x0,x1) => x0.contains(x1),
      _201: (x0,x1) => x0.querySelector(x1),
      _202: (x0,x1) => x0.matchMedia(x1),
      _203: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._203(f,arguments.length,x0) }),
      _204: (x0,x1,x2) => x0.call(x1,x2),
      _205: x0 => x0.blur(),
      _206: x0 => x0.hasFocus(),
      _207: (x0,x1) => x0.removeAttribute(x1),
      _208: (x0,x1,x2) => x0.insertBefore(x1,x2),
      _209: (x0,x1) => x0.hasAttribute(x1),
      _210: (x0,x1) => x0.getModifierState(x1),
      _211: (x0,x1) => x0.createTextNode(x1),
      _212: x0 => x0.getBoundingClientRect(),
      _213: (x0,x1) => x0.replaceWith(x1),
      _214: (x0,x1) => x0.contains(x1),
      _215: (x0,x1) => x0.closest(x1),
      _653: x0 => new Uint8Array(x0),
      _656: () => globalThis.window.flutterConfiguration,
      _658: x0 => x0.assetBase,
      _663: x0 => x0.canvasKitMaximumSurfaces,
      _664: x0 => x0.debugShowSemanticsNodes,
      _665: x0 => x0.hostElement,
      _666: x0 => x0.multiViewEnabled,
      _667: x0 => x0.nonce,
      _669: x0 => x0.fontFallbackBaseUrl,
      _679: x0 => x0.console,
      _680: x0 => x0.devicePixelRatio,
      _681: x0 => x0.document,
      _682: x0 => x0.history,
      _683: x0 => x0.innerHeight,
      _684: x0 => x0.innerWidth,
      _685: x0 => x0.location,
      _686: x0 => x0.navigator,
      _687: x0 => x0.visualViewport,
      _688: x0 => x0.performance,
      _689: x0 => x0.parent,
      _693: (x0,x1) => x0.getComputedStyle(x1),
      _694: x0 => x0.screen,
      _695: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._695(f,arguments.length,x0) }),
      _696: (x0,x1) => x0.requestAnimationFrame(x1),
      _700: (x0,x1) => x0.warn(x1),
      _702: (x0,x1) => x0.debug(x1),
      _703: x0 => globalThis.parseFloat(x0),
      _704: () => globalThis.window,
      _705: () => globalThis.Intl,
      _706: () => globalThis.Symbol,
      _709: x0 => x0.clipboard,
      _710: x0 => x0.maxTouchPoints,
      _711: x0 => x0.vendor,
      _712: x0 => x0.language,
      _713: x0 => x0.platform,
      _714: x0 => x0.userAgent,
      _715: (x0,x1) => x0.vibrate(x1),
      _716: x0 => x0.languages,
      _717: x0 => x0.documentElement,
      _718: (x0,x1) => x0.querySelector(x1),
      _719: (x0,x1) => x0.querySelectorAll(x1),
      _721: (x0,x1) => x0.createElement(x1),
      _724: (x0,x1) => x0.createEvent(x1),
      _725: x0 => x0.activeElement,
      _728: x0 => x0.head,
      _729: x0 => x0.body,
      _731: (x0,x1) => { x0.title = x1 },
      _734: x0 => x0.visibilityState,
      _735: () => globalThis.document,
      _736: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._736(f,arguments.length,x0) }),
      _737: (x0,x1) => x0.dispatchEvent(x1),
      _745: x0 => x0.target,
      _747: x0 => x0.timeStamp,
      _748: x0 => x0.type,
      _750: (x0,x1,x2,x3) => x0.initEvent(x1,x2,x3),
      _757: x0 => x0.firstChild,
      _761: x0 => x0.parentElement,
      _763: (x0,x1) => { x0.textContent = x1 },
      _764: x0 => x0.parentNode,
      _765: x0 => x0.nextSibling,
      _766: (x0,x1) => x0.removeChild(x1),
      _767: x0 => x0.isConnected,
      _775: x0 => x0.clientHeight,
      _776: x0 => x0.clientWidth,
      _777: x0 => x0.offsetHeight,
      _778: x0 => x0.offsetWidth,
      _779: x0 => x0.id,
      _780: (x0,x1) => { x0.id = x1 },
      _783: (x0,x1) => { x0.spellcheck = x1 },
      _784: x0 => x0.tagName,
      _785: x0 => x0.style,
      _787: (x0,x1) => x0.querySelectorAll(x1),
      _788: (x0,x1,x2) => x0.setAttribute(x1,x2),
      _789: x0 => x0.tabIndex,
      _790: (x0,x1) => { x0.tabIndex = x1 },
      _791: (x0,x1) => x0.focus(x1),
      _792: x0 => x0.scrollTop,
      _793: (x0,x1) => { x0.scrollTop = x1 },
      _794: (x0,x1) => { x0.scrollLeft = x1 },
      _795: x0 => x0.scrollLeft,
      _796: x0 => x0.classList,
      _797: (x0,x1) => x0.scrollIntoView(x1),
      _800: (x0,x1) => { x0.className = x1 },
      _802: (x0,x1) => x0.getElementsByClassName(x1),
      _803: x0 => x0.click(),
      _804: (x0,x1) => x0.attachShadow(x1),
      _807: x0 => x0.computedStyleMap(),
      _808: (x0,x1) => x0.get(x1),
      _814: (x0,x1) => x0.getPropertyValue(x1),
      _815: (x0,x1,x2,x3) => x0.setProperty(x1,x2,x3),
      _816: x0 => x0.offsetLeft,
      _817: x0 => x0.offsetTop,
      _818: x0 => x0.offsetParent,
      _820: (x0,x1) => { x0.name = x1 },
      _821: x0 => x0.content,
      _822: (x0,x1) => { x0.content = x1 },
      _840: (x0,x1) => { x0.nonce = x1 },
      _845: (x0,x1) => { x0.width = x1 },
      _847: (x0,x1) => { x0.height = x1 },
      _850: (x0,x1) => x0.getContext(x1),
      _918: x0 => x0.width,
      _919: x0 => x0.height,
      _921: (x0,x1) => x0.fetch(x1),
      _922: x0 => x0.status,
      _924: x0 => x0.body,
      _925: x0 => x0.arrayBuffer(),
      _928: x0 => x0.read(),
      _929: x0 => x0.value,
      _930: x0 => x0.done,
      _938: x0 => x0.x,
      _939: x0 => x0.y,
      _942: x0 => x0.top,
      _943: x0 => x0.right,
      _944: x0 => x0.bottom,
      _945: x0 => x0.left,
      _955: x0 => x0.height,
      _956: x0 => x0.width,
      _957: x0 => x0.scale,
      _958: (x0,x1) => { x0.value = x1 },
      _961: (x0,x1) => { x0.placeholder = x1 },
      _963: (x0,x1) => { x0.name = x1 },
      _964: x0 => x0.selectionDirection,
      _965: x0 => x0.selectionStart,
      _966: x0 => x0.selectionEnd,
      _969: x0 => x0.value,
      _971: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _972: x0 => x0.readText(),
      _973: (x0,x1) => x0.writeText(x1),
      _975: x0 => x0.altKey,
      _976: x0 => x0.code,
      _977: x0 => x0.ctrlKey,
      _978: x0 => x0.key,
      _979: x0 => x0.keyCode,
      _980: x0 => x0.location,
      _981: x0 => x0.metaKey,
      _982: x0 => x0.repeat,
      _983: x0 => x0.shiftKey,
      _984: x0 => x0.isComposing,
      _986: x0 => x0.state,
      _987: (x0,x1) => x0.go(x1),
      _989: (x0,x1,x2,x3) => x0.pushState(x1,x2,x3),
      _990: (x0,x1,x2,x3) => x0.replaceState(x1,x2,x3),
      _991: x0 => x0.pathname,
      _992: x0 => x0.search,
      _993: x0 => x0.hash,
      _997: x0 => x0.state,
      _1012: x0 => x0.matches,
      _1016: x0 => x0.matches,
      _1020: x0 => x0.relatedTarget,
      _1022: x0 => x0.clientX,
      _1023: x0 => x0.clientY,
      _1024: x0 => x0.offsetX,
      _1025: x0 => x0.offsetY,
      _1028: x0 => x0.button,
      _1029: x0 => x0.buttons,
      _1030: x0 => x0.ctrlKey,
      _1034: x0 => x0.pointerId,
      _1035: x0 => x0.pointerType,
      _1036: x0 => x0.pressure,
      _1037: x0 => x0.tiltX,
      _1038: x0 => x0.tiltY,
      _1039: x0 => x0.getCoalescedEvents(),
      _1042: x0 => x0.deltaX,
      _1043: x0 => x0.deltaY,
      _1044: x0 => x0.wheelDeltaX,
      _1045: x0 => x0.wheelDeltaY,
      _1046: x0 => x0.deltaMode,
      _1053: x0 => x0.changedTouches,
      _1056: x0 => x0.clientX,
      _1057: x0 => x0.clientY,
      _1060: x0 => x0.data,
      _1063: (x0,x1) => { x0.disabled = x1 },
      _1065: (x0,x1) => { x0.type = x1 },
      _1066: (x0,x1) => { x0.max = x1 },
      _1067: (x0,x1) => { x0.min = x1 },
      _1068: x0 => x0.value,
      _1069: (x0,x1) => { x0.value = x1 },
      _1070: x0 => x0.disabled,
      _1071: (x0,x1) => { x0.disabled = x1 },
      _1073: (x0,x1) => { x0.placeholder = x1 },
      _1075: (x0,x1) => { x0.name = x1 },
      _1076: (x0,x1) => { x0.autocomplete = x1 },
      _1078: x0 => x0.selectionDirection,
      _1079: x0 => x0.selectionStart,
      _1081: x0 => x0.selectionEnd,
      _1084: (x0,x1,x2) => x0.setSelectionRange(x1,x2),
      _1085: (x0,x1) => x0.add(x1),
      _1087: (x0,x1) => { x0.noValidate = x1 },
      _1088: (x0,x1) => { x0.method = x1 },
      _1089: (x0,x1) => { x0.action = x1 },
      _1114: x0 => x0.orientation,
      _1115: x0 => x0.width,
      _1116: x0 => x0.height,
      _1117: (x0,x1) => x0.lock(x1),
      _1136: x0 => new ResizeObserver(x0),
      _1139: (module,f) => finalizeWrapper(f, function(x0,x1) { return module.exports._1139(f,arguments.length,x0,x1) }),
      _1147: x0 => x0.length,
      _1148: x0 => x0.iterator,
      _1149: x0 => x0.Segmenter,
      _1150: x0 => x0.v8BreakIterator,
      _1151: (x0,x1) => new Intl.Segmenter(x0,x1),
      _1154: x0 => x0.language,
      _1155: x0 => x0.script,
      _1156: x0 => x0.region,
      _1174: x0 => x0.done,
      _1175: x0 => x0.value,
      _1176: x0 => x0.index,
      _1180: (x0,x1) => new Intl.v8BreakIterator(x0,x1),
      _1181: (x0,x1) => x0.adoptText(x1),
      _1182: x0 => x0.first(),
      _1183: x0 => x0.next(),
      _1184: x0 => x0.current(),
      _1186: () => globalThis.window.FinalizationRegistry,
      _1197: x0 => x0.hostElement,
      _1198: x0 => x0.viewConstraints,
      _1201: x0 => x0.maxHeight,
      _1202: x0 => x0.maxWidth,
      _1203: x0 => x0.minHeight,
      _1204: x0 => x0.minWidth,
      _1205: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1205(f,arguments.length,x0) }),
      _1206: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1206(f,arguments.length,x0) }),
      _1207: (x0,x1) => ({addView: x0,removeView: x1}),
      _1210: x0 => x0.loader,
      _1211: () => globalThis._flutter,
      _1212: (x0,x1) => x0.didCreateEngineInitializer(x1),
      _1213: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1213(f,arguments.length,x0) }),
      _1214: (module,f) => finalizeWrapper(f, function() { return module.exports._1214(f,arguments.length) }),
      _1215: (x0,x1) => ({initializeEngine: x0,autoStart: x1}),
      _1218: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1218(f,arguments.length,x0) }),
      _1219: x0 => ({runApp: x0}),
      _1221: (module,f) => finalizeWrapper(f, function(x0,x1) { return module.exports._1221(f,arguments.length,x0,x1) }),
      _1222: x0 => new Promise(x0),
      _1223: x0 => x0.length,
      _1297: x0 => x0.requestFullscreen(),
      _1298: x0 => x0.exitFullscreen(),
      _1299: x0 => x0.load(),
      _1300: x0 => x0.play(),
      _1301: x0 => x0.pause(),
      _1304: (x0,x1,x2) => x0.addEventListener(x1,x2),
      _1305: (x0,x1) => x0.removeAttribute(x1),
      _1306: (x0,x1,x2) => x0.removeEventListener(x1,x2),
      _1307: (x0,x1) => x0.start(x1),
      _1308: (x0,x1) => x0.end(x1),
      _1316: x0 => globalThis.Wakelock.toggle(x0),
      _1318: (x0,x1) => x0.querySelector(x1),
      _1319: (x0,x1) => x0.createElement(x1),
      _1320: (x0,x1) => x0.item(x1),
      _1321: () => new FileReader(),
      _1323: (x0,x1) => x0.readAsArrayBuffer(x1),
      _1324: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1324(f,arguments.length,x0) }),
      _1325: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1325(f,arguments.length,x0) }),
      _1326: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1326(f,arguments.length,x0) }),
      _1327: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1327(f,arguments.length,x0) }),
      _1328: (x0,x1) => x0.removeChild(x1),
      _1329: x0 => x0.click(),
      _1333: Date.now,
      _1335: s => new Date(s * 1000).getTimezoneOffset() * 60,
      _1336: s => {
        if (!/^\s*[+-]?(?:Infinity|NaN|(?:\.\d+|\d+(?:\.\d*)?)(?:[eE][+-]?\d+)?)\s*$/.test(s)) {
          return NaN;
        }
        return parseFloat(s);
      },
      _1337: () => typeof dartUseDateNowForTicks !== "undefined",
      _1338: () => 1000 * performance.now(),
      _1339: () => Date.now(),
      _1342: () => new WeakMap(),
      _1343: (map, o) => map.get(o),
      _1344: (map, o, v) => map.set(o, v),
      _1345: x0 => new WeakRef(x0),
      _1346: x0 => x0.deref(),
      _1353: () => globalThis.WeakRef,
      _1357: s => JSON.stringify(s),
      _1358: s => printToConsole(s),
      _1359: o => {
        if (o === null || o === undefined) return 0;
        if (typeof(o) === 'string') return 1;
        return 2;
      },
      _1360: (o, p, r) => o.replaceAll(p, () => r),
      _1362: Function.prototype.call.bind(String.prototype.toLowerCase),
      _1363: s => s.toUpperCase(),
      _1364: s => s.trim(),
      _1365: s => s.trimLeft(),
      _1366: s => s.trimRight(),
      _1367: (string, times) => string.repeat(times),
      _1368: Function.prototype.call.bind(String.prototype.indexOf),
      _1369: (s, p, i) => s.lastIndexOf(p, i),
      _1370: (string, token) => string.split(token),
      _1371: Object.is,
      _1376: (o, c) => o instanceof c,
      _1377: o => Object.keys(o),
      _1381: (o, a) => o + a,
      _1431: x0 => new Array(x0),
      _1433: x0 => x0.length,
      _1435: (x0,x1) => x0[x1],
      _1436: (x0,x1,x2) => { x0[x1] = x2 },
      _1439: (x0,x1,x2) => new DataView(x0,x1,x2),
      _1441: x0 => new Int8Array(x0),
      _1442: (x0,x1,x2) => new Uint8Array(x0,x1,x2),
      _1444: x0 => new Uint8ClampedArray(x0),
      _1446: x0 => new Int16Array(x0),
      _1448: x0 => new Uint16Array(x0),
      _1450: x0 => new Int32Array(x0),
      _1452: x0 => new Uint32Array(x0),
      _1454: x0 => new Float32Array(x0),
      _1456: x0 => new Float64Array(x0),
      _1480: x0 => x0.random(),
      _1483: () => globalThis.Math,
      _1496: (ms, c) =>
      setTimeout(() => dartInstance.exports.$invokeCallback(c),ms),
      _1497: (handle) => clearTimeout(handle),
      _1498: (ms, c) =>
      setInterval(() => dartInstance.exports.$invokeCallback(c), ms),
      _1499: (handle) => clearInterval(handle),
      _1500: (c) =>
      queueMicrotask(() => dartInstance.exports.$invokeCallback(c)),
      _1501: () => Date.now(),
      _1502: () => new Error().stack,
      _1503: (exn) => {
        let stackString = exn.toString();
        let frames = stackString.split('\n');
        let drop = 4;
        if (frames[0].startsWith('Error')) {
            drop += 1;
        }
        return frames.slice(drop).join('\n');
      },
      _1504: (s, m) => {
        try {
          return new RegExp(s, m);
        } catch (e) {
          return String(e);
        }
      },
      _1505: (x0,x1) => x0.exec(x1),
      _1506: (x0,x1) => x0.test(x1),
      _1507: x0 => x0.pop(),
      _1509: o => o === undefined,
      _1511: o => typeof o === 'function' && o[jsWrappedDartFunctionSymbol] === true,
      _1513: o => {
        const proto = Object.getPrototypeOf(o);
        return proto === Object.prototype || proto === null;
      },
      _1514: o => o instanceof RegExp,
      _1515: (l, r) => l === r,
      _1516: o => o,
      _1517: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'number') return 1;
        return 2;
      },
      _1518: o => o,
      _1519: o => {
        if (o === undefined || o === null) return 0;
        if (typeof o === 'boolean') return 1;
        return 2;
      },
      _1520: o => o,
      _1521: b => !!b,
      _1522: o => o.length,
      _1524: (o, i) => o[i],
      _1525: f => f.dartFunction,
      _1526: () => ({}),
      _1527: () => [],
      _1529: () => globalThis,
      _1530: (constructor, args) => {
        const factoryFunction = constructor.bind.apply(
            constructor, [null, ...args]);
        return new factoryFunction();
      },
      _1532: (o, p) => o[p],
      _1533: (o, p, v) => o[p] = v,
      _1534: (o, m, a) => o[m].apply(o, a),
      _1536: o => String(o),
      _1537: (p, s, f) => p.then(s, (e) => f(e, e === undefined)),
      _1538: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1538(f,arguments.length,x0) }),
      _1539: (module,f) => finalizeWrapper(f, function(x0,x1) { return module.exports._1539(f,arguments.length,x0,x1) }),
      _1540: o => {
        if (o === undefined) return 1;
        var type = typeof o;
        if (type === 'boolean') return 2;
        if (type === 'number') return 3;
        if (type === 'string') return 4;
        if (o instanceof Array) return 5;
        if (ArrayBuffer.isView(o)) {
          if (o instanceof Int8Array) return 6;
          if (o instanceof Uint8Array) return 7;
          if (o instanceof Uint8ClampedArray) return 8;
          if (o instanceof Int16Array) return 9;
          if (o instanceof Uint16Array) return 10;
          if (o instanceof Int32Array) return 11;
          if (o instanceof Uint32Array) return 12;
          if (o instanceof Float32Array) return 13;
          if (o instanceof Float64Array) return 14;
          if (o instanceof DataView) return 15;
        }
        if (o instanceof ArrayBuffer) return 16;
        // Feature check for `SharedArrayBuffer` before doing a type-check.
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
            return 17;
        }
        if (o instanceof Promise) return 18;
        return 19;
      },
      _1541: o => [o],
      _1542: (o0, o1) => [o0, o1],
      _1543: (o0, o1, o2) => [o0, o1, o2],
      _1544: (o0, o1, o2, o3) => [o0, o1, o2, o3],
      _1545: (exn) => {
        if (exn instanceof Error) {
          return exn.stack;
        } else {
          return null;
        }
      },
      _1546: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI8ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1547: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI8ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1550: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmI32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1551: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmI32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1552: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF32ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1553: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF32ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1554: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const getValue = dartInstance.exports.$wasmF64ArrayGet;
        for (let i = 0; i < length; i++) {
          jsArray[jsArrayOffset + i] = getValue(wasmArray, wasmArrayOffset + i);
        }
      },
      _1555: (jsArray, jsArrayOffset, wasmArray, wasmArrayOffset, length) => {
        const setValue = dartInstance.exports.$wasmF64ArraySet;
        for (let i = 0; i < length; i++) {
          setValue(wasmArray, wasmArrayOffset + i, jsArray[jsArrayOffset + i]);
        }
      },
      _1556: x0 => new ArrayBuffer(x0),
      _1557: s => {
        if (/[[\]{}()*+?.\\^$|]/.test(s)) {
            s = s.replace(/[[\]{}()*+?.\\^$|]/g, '\\$&');
        }
        return s;
      },
      _1559: x0 => x0.index,
      _1561: x0 => x0.flags,
      _1562: x0 => x0.multiline,
      _1563: x0 => x0.ignoreCase,
      _1564: x0 => x0.unicode,
      _1565: x0 => x0.dotAll,
      _1566: (x0,x1) => { x0.lastIndex = x1 },
      _1567: (o, p) => p in o,
      _1568: (o, p) => o[p],
      _1578: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1578(f,arguments.length,x0) }),
      _1579: (module,f) => finalizeWrapper(f, function(x0) { return module.exports._1579(f,arguments.length,x0) }),
      _1580: (x0,x1,x2,x3) => x0.addEventListener(x1,x2,x3),
      _1581: (x0,x1,x2,x3) => x0.removeEventListener(x1,x2,x3),
      _1586: (x0,x1) => x0.appendChild(x1),
      _1590: (x0,x1) => x0.item(x1),
      _1604: o => o instanceof Array,
      _1608: a => a.pop(),
      _1609: (a, i) => a.splice(i, 1),
      _1610: (a, s) => a.join(s),
      _1611: (a, s, e) => a.slice(s, e),
      _1614: a => a.length,
      _1616: (a, i) => a[i],
      _1617: (a, i, v) => a[i] = v,
      _1619: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof ArrayBuffer) return 1;
        if (globalThis.SharedArrayBuffer !== undefined &&
            o instanceof SharedArrayBuffer) {
          return 2;
        }
        return 3;
      },
      _1620: (o, offsetInBytes, lengthInBytes) => {
        var dst = new ArrayBuffer(lengthInBytes);
        new Uint8Array(dst).set(new Uint8Array(o, offsetInBytes, lengthInBytes));
        return new DataView(dst);
      },
      _1622: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint8Array) return 1;
        return 2;
      },
      _1623: (o, start, length) => new Uint8Array(o.buffer, o.byteOffset + start, length),
      _1624: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int8Array) return 1;
        return 2;
      },
      _1625: (o, start, length) => new Int8Array(o.buffer, o.byteOffset + start, length),
      _1626: o => o instanceof Uint8ClampedArray,
      _1627: (o, start, length) => new Uint8ClampedArray(o.buffer, o.byteOffset + start, length),
      _1628: o => o instanceof Uint16Array,
      _1629: (o, start, length) => new Uint16Array(o.buffer, o.byteOffset + start, length),
      _1630: o => o instanceof Int16Array,
      _1631: (o, start, length) => new Int16Array(o.buffer, o.byteOffset + start, length),
      _1632: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Uint32Array) return 1;
        return 2;
      },
      _1633: (o, start, length) => new Uint32Array(o.buffer, o.byteOffset + start, length),
      _1634: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Int32Array) return 1;
        return 2;
      },
      _1635: (o, start, length) => new Int32Array(o.buffer, o.byteOffset + start, length),
      _1637: (o, start, length) => new BigInt64Array(o.buffer, o.byteOffset + start, length),
      _1638: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float32Array) return 1;
        return 2;
      },
      _1639: (o, start, length) => new Float32Array(o.buffer, o.byteOffset + start, length),
      _1640: o => {
        if (o === null || o === undefined) return 0;
        if (o instanceof Float64Array) return 1;
        return 2;
      },
      _1641: (o, start, length) => new Float64Array(o.buffer, o.byteOffset + start, length),
      _1642: (a, i) => a.push(i),
      _1643: (t, s) => t.set(s),
      _1645: (o) => new DataView(o.buffer, o.byteOffset, o.byteLength),
      _1647: o => o.buffer,
      _1648: o => o.byteOffset,
      _1649: Function.prototype.call.bind(Object.getOwnPropertyDescriptor(DataView.prototype, 'byteLength').get),
      _1650: (b, o) => new DataView(b, o),
      _1651: (b, o, l) => new DataView(b, o, l),
      _1652: Function.prototype.call.bind(DataView.prototype.getUint8),
      _1653: Function.prototype.call.bind(DataView.prototype.setUint8),
      _1654: Function.prototype.call.bind(DataView.prototype.getInt8),
      _1655: Function.prototype.call.bind(DataView.prototype.setInt8),
      _1656: Function.prototype.call.bind(DataView.prototype.getUint16),
      _1657: Function.prototype.call.bind(DataView.prototype.setUint16),
      _1658: Function.prototype.call.bind(DataView.prototype.getInt16),
      _1659: Function.prototype.call.bind(DataView.prototype.setInt16),
      _1660: Function.prototype.call.bind(DataView.prototype.getUint32),
      _1661: Function.prototype.call.bind(DataView.prototype.setUint32),
      _1662: Function.prototype.call.bind(DataView.prototype.getInt32),
      _1663: Function.prototype.call.bind(DataView.prototype.setInt32),
      _1666: Function.prototype.call.bind(DataView.prototype.getBigInt64),
      _1667: Function.prototype.call.bind(DataView.prototype.setBigInt64),
      _1668: Function.prototype.call.bind(DataView.prototype.getFloat32),
      _1669: Function.prototype.call.bind(DataView.prototype.setFloat32),
      _1670: Function.prototype.call.bind(DataView.prototype.getFloat64),
      _1671: Function.prototype.call.bind(DataView.prototype.setFloat64),
      _1672: Function.prototype.call.bind(Number.prototype.toString),
      _1673: Function.prototype.call.bind(BigInt.prototype.toString),
      _1674: Function.prototype.call.bind(Number.prototype.toString),
      _1675: (d, digits) => d.toFixed(digits),
      _1692: () => globalThis.console,
      _1731: (x0,x1) => x0.error(x1),
      _1853: (x0,x1) => { x0.draggable = x1 },
      _1869: x0 => x0.style,
      _2441: x0 => x0.videoWidth,
      _2442: x0 => x0.videoHeight,
      _2446: (x0,x1) => { x0.playsInline = x1 },
      _2472: x0 => x0.error,
      _2474: (x0,x1) => { x0.src = x1 },
      _2483: x0 => x0.buffered,
      _2486: x0 => x0.currentTime,
      _2487: (x0,x1) => { x0.currentTime = x1 },
      _2488: x0 => x0.duration,
      _2493: (x0,x1) => { x0.playbackRate = x1 },
      _2500: (x0,x1) => { x0.autoplay = x1 },
      _2502: (x0,x1) => { x0.loop = x1 },
      _2504: (x0,x1) => { x0.controls = x1 },
      _2506: (x0,x1) => { x0.volume = x1 },
      _2508: (x0,x1) => { x0.muted = x1 },
      _2523: x0 => x0.code,
      _2524: x0 => x0.message,
      _2597: x0 => x0.length,
      _2793: (x0,x1) => { x0.accept = x1 },
      _2807: x0 => x0.files,
      _2833: (x0,x1) => { x0.multiple = x1 },
      _2851: (x0,x1) => { x0.type = x1 },
      _3100: x0 => x0.src,
      _3101: (x0,x1) => { x0.src = x1 },
      _3103: (x0,x1) => { x0.type = x1 },
      _3107: (x0,x1) => { x0.async = x1 },
      _3121: (x0,x1) => { x0.charset = x1 },
      _3570: () => globalThis.window,
      _6189: x0 => x0.length,
      _6238: x0 => x0.firstChild,
      _6249: () => globalThis.document,
      _6309: x0 => x0.documentElement,
      _6332: x0 => x0.head,
      _6667: (x0,x1) => { x0.id = x1 },
      _6694: x0 => x0.children,
      _8195: x0 => x0.size,
      _8203: x0 => x0.name,
      _8209: x0 => x0.length,
      _8214: x0 => x0.result,
      _10845: (x0,x1) => { x0.border = x1 },
      _11123: (x0,x1) => { x0.display = x1 },
      _11287: (x0,x1) => { x0.height = x1 },
      _11977: (x0,x1) => { x0.width = x1 },
      _12345: x0 => x0.name,
      _12346: x0 => x0.message,

    };

    const baseImports = {
      dart2wasm: dart2wasm,
      Math: Math,
      Date: Date,
      Object: Object,
      Array: Array,
      Reflect: Reflect,
      WebAssembly: {
        JSTag: WebAssembly.JSTag,
      },
      "": new Proxy({}, { get(_, prop) { return prop; } }),

    };

    const jsStringPolyfill = {
      "charCodeAt": (s, i) => s.charCodeAt(i),
      "compare": (s1, s2) => {
        if (s1 < s2) return -1;
        if (s1 > s2) return 1;
        return 0;
      },
      "concat": (s1, s2) => s1 + s2,
      "equals": (s1, s2) => s1 === s2,
      "fromCharCode": (i) => String.fromCharCode(i),
      "length": (s) => s.length,
      "substring": (s, a, b) => s.substring(a, b),
      "fromCharCodeArray": (a, start, end) => {
        if (end <= start) return '';

        const read = dartInstance.exports.$wasmI16ArrayGet;
        let result = '';
        let index = start;
        const chunkLength = Math.min(end - index, 500);
        let array = new Array(chunkLength);
        while (index < end) {
          const newChunkLength = Math.min(end - index, 500);
          for (let i = 0; i < newChunkLength; i++) {
            array[i] = read(a, index++);
          }
          if (newChunkLength < chunkLength) {
            array = array.slice(0, newChunkLength);
          }
          result += String.fromCharCode(...array);
        }
        return result;
      },
      "intoCharCodeArray": (s, a, start) => {
        if (s === '') return 0;

        const write = dartInstance.exports.$wasmI16ArraySet;
        for (var i = 0; i < s.length; ++i) {
          write(a, start++, s.charCodeAt(i));
        }
        return s.length;
      },
      "test": (s) => typeof s == "string",
    };


    

    dartInstance = await WebAssembly.instantiate(this.module, {
      ...baseImports,
      ...additionalImports,
      
      "wasm:js-string": jsStringPolyfill,
    });
    dartInstance.exports.$setThisModule(dartInstance);

    return new InstantiatedApp(this, dartInstance);
  }
}

class InstantiatedApp {
  constructor(compiledApp, instantiatedModule) {
    this.compiledApp = compiledApp;
    this.instantiatedModule = instantiatedModule;
  }

  // Call the main function with the given arguments.
  invokeMain(...args) {
    this.instantiatedModule.exports.$invokeMain(args);
  }
}
