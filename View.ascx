<%@ Control Language="C#" AutoEventWireup="false" Inherits="Satrabel.OpenForm.View" CodeBehind="View.ascx.cs" %>
<%@ Register TagPrefix="dnncl" Namespace="DotNetNuke.Web.Client.ClientResourceManagement" Assembly="DotNetNuke.Web.Client" %>
<dnncl:DnnJsInclude ID="DnnJsInclude1" runat="server" FilePath="~/DesktopModules/OpenContent/js/alpaca-1.5.8/lib/handlebars/handlebars.js" Priority="106" ForceProvider="DnnPageHeaderProvider" />
<dnncl:DnnJsInclude ID="DnnJsInclude2" runat="server" FilePath="~/DesktopModules/OpenContent/js/alpaca-1.5.8/alpaca/bootstrap/alpaca.js" Priority="107" ForceProvider="DnnPageHeaderProvider" />
<script src="/DesktopModules/OpenContent/js/wysihtml/wysihtml-toolbar.js"></script>
<script src="/DesktopModules/OpenContent/js/wysihtml/parser_rules/advanced.js"></script>
<script type="text/javascript" src="/DesktopModules/OpenContent/alpaca/js/fields/dnn/ImageField.js"></script>
<script type="text/javascript" src="/DesktopModules/OpenContent/alpaca/js/fields/dnn/wysihtmlField.js"></script>

<asp:Panel ID="ScopeWrapper" runat="server">
    <div id="OpenForm">
        <div id="field1" class="alpaca"></div>
        <ul class="dnnActions dnnClear" style="display:block;padding-left:35%">
            <li>
                <asp:HyperLink ID="cmdSave" runat="server" class="dnnPrimaryAction" resourcekey="cmdSave" /></li>
        </ul>
    </div>
    <span id="ResultMessage"></span>
</asp:Panel>

<script type="text/javascript">
    $(document).ready(function () {

        $.alpaca.setDefaultLocale("<%= CurrentCulture %>");
        
        var moduleScope = $('#<%=ScopeWrapper.ClientID %>'),
            self = moduleScope,
            sf = $.ServicesFramework(<%=ModuleId %>);

        var postData = {};
        //var getData = "tabId=<%=TabId %>&moduleId=<%=ModuleId %>";
        var getData = "";
        var action = "Form"; //self.getUpdateAction();

        $.ajax({
            type: "GET",
            url: sf.getServiceRoot('OpenForm') + "OpenFormAPI/" + action,
            data: getData,
            beforeSend: sf.setModuleHeaders
        }).done(function (config) {
            //alert('ok:' + JSON.stringify(config));
            
            var ConnectorClass = Alpaca.getConnectorClass("default");
            connector = new ConnectorClass("default");
            connector.servicesFramework = sf;

            $.alpaca.Fields.DnnFileField = $.alpaca.Fields.FileField.extend({
                setup: function () {
                    this.base();
                },
                afterRenderControl: function (model, callback) {
                    var self = this;
                    this.base(model, function () {
                        self.handlePostRender(function () {
                            callback();
                        });
                    });
                },
                handlePostRender: function (callback) {
                    //var self = this;
                    var el = this.control;
                    self.SetupFileUpload(el);
                    callback();
                }
            });
            Alpaca.registerFieldClass("file", Alpaca.Fields.DnnFileField);

            $("#field1").alpaca({
                "schema": config.schema,
                "options": config.options,
                "data": config.data,
                "view": "bootstrap-create",
                "connector": connector,
                "postRender": function (control) {
                    var selfControl = control;
                    $("#<%=cmdSave.ClientID%>").click(function () {
                        selfControl.refreshValidationState(true);
                        if (selfControl.isValid(true)) {
                            var value = selfControl.getValue();
                            //alert(JSON.stringify(value, null, "  "));
                            var href = $(this).attr('href');
                            self.FormSubmit(value, href);
                        }
                        return false;
                    });
                    $('#field1').dnnPanels();
                    $('.dnnTooltip').dnnTooltip();

                }
            });
        }).fail(function (xhr, result, status) {
            //alert("Uh-oh, something broke: " + status);
            alert(status + " : " + xhr.responseText);
        });

        self.FormSubmit = function (data, href) {
            var postData = data;
            var action = "Submit"; //self.getUpdateAction();

            $.ajax({
                type: "POST",
                url: sf.getServiceRoot('OpenForm') + "OpenFormAPI/" + action,
                data: postData,
                beforeSend: sf.setModuleHeaders
            }).done(function (data) {
                //alert('ok:' + data);
                
                $('#OpenForm', moduleScope).hide();
                $('#ResultMessage', moduleScope).html(data.Message);
                //window.location.href = href;
            }).fail(function (xhr, result, status) {
                //alert("Uh-oh, something broke: " + status);
                alert(status + " : " + xhr.responseText);
            });
        };

        self.SetupFileUpload = function (fileupload) {

            //$('#field1 input[type="file"]')
            $(fileupload).fileupload({
                dataType: 'json',
                url: sf.getServiceRoot('Satrabel.Content') + "FileUpload/UploadFile",
                maxFileSize: 25000000,
                formData: { example: 'test' },
                beforeSend: sf.setModuleHeaders,
                add: function (e, data) {
                    //data.context = $(opts.progressContextSelector);
                    //data.context.find($(opts.progressFileNameSelector)).html(data.files[0].name);
                    //data.context.show('fade');
                    data.submit();
                },
                progress: function (e, data) {
                    if (data.context) {
                        var progress = parseInt(data.loaded / data.total * 100, 10);
                        data.context.find(opts.progressBarSelector).css('width', progress + '%').find('span').html(progress + '%');
                    }
                },
                done: function (e, data) {
                    if (data.result) {
                        $.each(data.result, function (index, file) {
                            //$('<p/>').text(file.name).appendTo($(e.target).parent().parent());
                            //$('<img/>').attr('src', file.url).appendTo($(e.target).parent().parent());

                            $(e.target).closest('.alpaca-container').find('.alpaca-field-image input').val(file.url);
                            $(e.target).closest('.alpaca-container').find('.alpaca-image-display img').attr('src', file.url);
                        });
                    }
                }
            }).data('loaded', true);
        }
    });
</script>
