// Highlight UV caption when clicked
$(document).ready(function() {
  $(document).on('click', 'a.highlight-uv-caption', function(e) {
    // Get the UV iframe
    var uvIframe = document.getElementById('uv-iframe');
    
    if (uvIframe && uvIframe.contentWindow) {
      try {
        // Access the iframe's document
        var iframeDoc = uvIframe.contentWindow.document || uvIframe.contentDocument;
        
        // Target the specific element
        var targetSelector = '#uv > div > div > div.mainPanel.leftPanelOpen.rightPanelOpen > div.rightPanel.open.open-finished > div.main > article > div.groups > div:nth-child(2) > div.items > div.item._image-_caption > div.values > div';
        var targetElement = iframeDoc.querySelector(targetSelector);
        
        if (targetElement) {
          // Apply the yellow background
          targetElement.style.background = 'yellow';
        }
      } catch (error) {
        // Handle cross-origin iframe access errors
        console.error('Error accessing UV iframe:', error);
      }
    }
  });
});

