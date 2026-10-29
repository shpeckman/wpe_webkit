# AGENTS.md

How AI agents should work on the `wpe_webkit` shard: hand-written Crystal bindings for WPE WebKit 2.x on the WPE Platform API.

## Repository layout

```
shard.yml
src/wpe_webkit.cr                    entry; require order matters (see below)
src/wpe_webkit/c/glib.cr             lib C: GLib/GObject/GIO structs and funs, poll(2)
src/wpe_webkit/c/soup.cr             lib C: libsoup cookies and message headers
src/wpe_webkit/c/webkit.cr           lib C: WebKit UI-process API
src/wpe_webkit/c/jsc.cr              lib C: JavaScriptCore values
src/wpe_webkit/c/wpe.cr              lib C: WPE Platform display/toplevel/view
src/wpe_webkit/error.cr              GLibError (from_raw/take/check!)
src/wpe_webkit/native.cr             string, strv, GList and GBytes helpers
src/wpe_webkit/handles.cr            retains Crystal values passed to C as user_data
src/wpe_webkit/wrapper.cr            ownership base: ref/unref, from_raw/take, owner retention, `boxed` macro
src/wpe_webkit/g_object.cr           GObject base: properties/notify/signal macros, construct, property IO
src/wpe_webkit/enums.cr              every enum and flags type
src/wpe_webkit/async.cr              GAsyncReadyCallback -> blocking result (Async.await)
src/wpe_webkit/main_loop.cr          main-fiber GLib loop, poll thread, run/quit
src/wpe_webkit/*.cr                  one file per API area (web_view, settings, network_session, ...)
spec/                                specs; spec_helper provides a headless DISPLAY and loop helpers
```

`src/wpe_webkit.cr` requires `c/*`, error, native, handles, wrapper, g_object, enums, async and main_loop explicitly, in that order, before the glob. The `signal` macro uses `Path#resolve?` to tell enums apart from wrappers, so enums must be defined before any class that declares signals.

## Commands

```sh
crystal spec                      # all specs (headless, spawns WPEWebProcess)
crystal spec spec/web_view_spec.cr
crystal tool format src spec
ameba src spec
crystal build --no-codegen spec/web_view_spec.cr   # quick type check
```

## Architecture rules

- **Main fiber only.** JSC aborts (`sanitizeStackForVM`) when it runs on a Crystal fiber stack. `MainLoop.iterate` and `Async.await` raise `WrongFiberError` off the main fiber. Do not reintroduce a spawned loop fiber.
- **Polling.** `MainLoop.iterate` does prepare/query/check/dispatch by hand. A non-zero timeout is handed to `Poller`: a thread that blocks in poll(2) and wakes the main fiber through an evented pipe, so other fibers run meanwhile.
- **Ownership.**
  - Transfer-full returns use `take`; transfer-none returns use `from_raw`, which refs.
  - Boxed types declare `boxed ref_fn, unref_fn`.
  - Child objects that must not outlive their parent (cookie/data managers, find controller, toplevel, request/response accessors) are created with `from_raw(ptr, owner: self)`. Boehm then finalizes the child first.
- **Signals.** Add them to the `signal` table in the class: `signal name, "c-name", {arg: Type}, ReturnType`.
  - Param kinds: `Bool`, `String`, `Int32`/`UInt32`/`UInt64`/`Float64`, `Pointer(Void)`, any enum, or any type with `from_raw(Void*)`.
  - Return kinds: `Nil`, `Bool`, or a GObject wrapper (returned with a new ref).
  - `detailed: true` adds a leading `detail : String` argument.
  - Property change signals use `notify name, "property-name", Type`.
- **Properties.** Simple GObject properties go in a `properties({...})` table. Names map underscore → dash.
- **Async.** Wrap `*_async`/`*_finish` pairs with `Async.await(->(result, error) { finish }) { |callback, data| start }`.
- **Callbacks into C** are non-closure procs. Pass Crystal state through `Handles.retain`, which releases on `GClosureNotify`/`GDestroyNotify`. Rescue every exception inside a callback: none may unwind through C frames.
- **Type names.** Pick runtime subclasses with `GObject.type_name` lookups in a constant table (see `PolicyDecision::SUBCLASSES` and `PermissionRequest::KINDS`).

## Code standards

- Compiler-friendly, performance-focused, idiomatic Crystal.
- Data-driven design: tables (`properties`, `signal`, constant hashes) over repeated hand-written code.
- No comments in code, except that every file starts with a comment holding its path (e.g. `# src/wpe_webkit/web_view.cr`).
- Ergonomic user-facing API: Crystal types (`String?`, `HTTP::Headers`, `HTTP::Cookie`, enums with symbol autocasting, `Time::Span`), blocking results instead of callbacks, `?` for Bool getters.
- Prevent shotgun surgery: a new signal, property or enum value should touch one table.
- Keep `README.md` (usage and public API) and this file in sync with the code.
- Do not change the version in `shard.yml`.
