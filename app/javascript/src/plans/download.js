document.addEventListener("turbo:load", () => {
  // Add a target="_blank" to the form when PDF or HTML are selected
  // Hide the PDF Formatting section if 'pdf' is not the desired format
  let downloadFormat = "pdf";
  const checkSelectedCount = () => {
    if (downloadFormat !== "pdf") return;

    const selectedCount = $(".research-output-checkbox:checked").length;
    const totalCount = $(".research-output-checkbox").length;
    if (selectedCount > 15) {
      $(".download-btn").attr("disabled", true);
      $(".download-btn-tooltip").show();
    }

    if (selectedCount <= 15 || selectedCount === totalCount) {
      $(".download-btn").attr("disabled", false);
      $(".download-btn-tooltip").hide();
    }
  };
  $("#download_form select#format")
    .on("change", () => {
      downloadFormat = $("#download_form select#format").val();
      if (
        downloadFormat === "pdf" ||
        downloadFormat === "html" ||
        downloadFormat === "json"
      ) {
        $("#download_form").attr("target", "_blank");
      } else {
        $("#download_form").removeAttr("target");
      }

      if (downloadFormat === "pdf") {
        $("#pdf-formatting").show();
        $("#large-plan-warning").show();
        checkSelectedCount();
      } else {
        $("#pdf-formatting").hide();
        $(".download-btn").attr("disabled", false);
        $(".download-btn-tooltip").hide();
        $("#large-plan-warning").hide();
      }

      if (downloadFormat === "json") {
        $("#research-output-export-mode, #export-options").hide();
        $("#json-formatting").show();
        $("#download-settings").hide();
      } else {
        $("#research-output-export-mode, #export-options").show();
        $("#json-formatting").hide();
        $("#download-settings").show();
      }

      if (downloadFormat === "csv") {
        $("#phase_id").find('option[value="All"').hide();
        $("#phase_id option:eq(1)").attr("selected", "selected");
        $("#phase_id").val($("#phase_id option:eq(1)").val());
      } else if (
        downloadFormat === "pdf" ||
        downloadFormat === "html" ||
        downloadFormat === "docx" ||
        downloadFormat === "text"
      ) {
        $("#phase_id").find('option[value="All"').show();
        $("#phase_id").val($("#phase_id option:first").val());
        $("#phase_id option:first").attr("selected", "selected");
      }
    })
    .trigger("change");

  $("#select-all-phases").on("click", (e) => {
    if (e.target.checked) {
      // Iterate each checkbox
      $(".phase-checkbox").each(function check() {
        this.checked = true;
      });
    } else {
      $(".phase-checkbox").each(function check() {
        this.checked = false;
      });
    }
  });

  $("#select-all-research-outputs").on("click", (e) => {
    if (e.target.checked) {
      // Iterate each checkbox
      $(".research-output-checkbox").each(function check() {
        this.checked = true;
        $(".download-btn").attr("disabled", false);
        $(".download-btn-tooltip").hide();
      });
    } else {
      $(".research-output-checkbox").each(function check() {
        this.checked = false;
      });
    }
  });
  $(".research-output-checkbox").on("click", () => {
    checkSelectedCount();
  });
});
