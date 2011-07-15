window.addEvent('domready', function() {

    /**
     * Uploader instance
     */
    var up = new FancyUpload3.Attach('uploader_file_list', '#upload_link', {
      path: 'http://localhost:3000/javascripts/fancyupload/source/Swiff.Uploader.swf',
      url: 'http://localhost:3000/upload/upload',
      fieldName: 'file',
      //fileSizeMax 500 Mo
      fileSizeMax: 500 * 1024 * 1024 * 1024,

      //verbose: true,

     		// graceful degradation, onLoad is only called if all went well with Flash
		onLoad: function() {
			$('flash').style.display = 'block'; // we show the actual UI
			$('no_flash').destroy(); // ... and hide the plain form
		},

     /**
		 * onFail is called when the Flash movie got bashed by some browser plugin
		 * like Adblock or Flashblock.
		 */
		onFail: function(error) {
					//alert(error)
		},

      onSelectFail: function(files) {
        files.each(function(file) {
          new Element('li', {
            'class': 'file-invalid',
            events: {
              click: function() {
                this.destroy();
              }
            }
          }).adopt(
            new Element('span', {html: file.validationErrorMessage || file.validationError})
          ).inject(this.list, 'bottom');
        }, this);
      },

      onFileComplete: function(file) {
        if (file.response.code == 201 || file.response.code == 0){
          file.ui.element.highlight('#e6efc2');
          file.ui.element.children[2].setStyle('display','none');
          file.ui.element.children[3].setStyle('display','none');
        }
      },

      onFileError: function(file) {
        if (file.response.code != 201){
          file.ui.cancel.set('html', 'Retry').removeEvents().addEvent('click', function() {
            file.requeue();
            return false;
          });

          new Element('span', {
            html: file.errorMessage,
            'class': 'file-error'
          }).inject(file.ui.cancel, 'after'); }
      },

      onFileRequeue: function(file) {
        file.ui.element.getElement('.file-error').destroy();

        file.ui.cancel.set('html', 'Cancel').removeEvents().addEvent('click', function() {
          file.remove();
          return false;
        });

        this.start();
      }

      });

    });