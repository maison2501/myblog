import EasyMDE from 'easymde';

window.onload = function () {
    // textareaをMarkdownエディタにする
    var easyMDE = new EasyMDE({
        uploadImage: true,
        imagePathAbsolute: true,
        element: document.getElementById('editor')
    });
  };