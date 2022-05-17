import EasyMDE from 'easymde';
import "easymde/dist/easymde.min.css";

onload = function () {
    // textareaをMarkdownエディタにする
    var easyMDE = new EasyMDE({
        uploadImage: true,
        imagePathAbsolute: true,
        element: document.getElementById('editor')
    });
};