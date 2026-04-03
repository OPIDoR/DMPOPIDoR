document.addEventListener('turbo:load', () => {
  $('#research-outputs').sortable({
    items: '.research-output-element:not(.inactive)',
    handle: '.research-output-actions .handle',
    update: () => {
      const updatedOrder = [];
      const planId = $('#research-outputs #plan_id').val();
      $('#research-outputs .research-output-element').each(function callback() {
        updatedOrder.push($(this).find('.research-output-id').val());
      });
      $.ajax({
        url: '/classic_research_outputs/sort',
        method: 'post',
        data: {
          plan_id: planId,
          updated_order: updatedOrder,
        },
      });
    },
  });
});
