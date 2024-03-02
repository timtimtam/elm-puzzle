/* elm-pkg-js
port supermario_copy_to_clipboard_to_js : String -> Cmd msg
*/

exports.init = async function (app) {  
  const targetDiv = document.getElementById("overlay-div")

  document.addEventListener("pointerlockchange", onLockChange, false);

  function onLockChange(event) {
    if (document.pointerLockElement === targetDiv) {
      app.ports.gotPointerLock.send({
        msg: "GotPointerLock"
      });
    }
    else {
      app.ports.gotPointerLock.send({
        msg: "LostPointerLock"
      });
    }
  }

  app.ports.requestPointerLock.subscribe(function (integer) {
    targetDiv.requestPointerLock({
      unadjustedMovement: true,
    });
  });
};
