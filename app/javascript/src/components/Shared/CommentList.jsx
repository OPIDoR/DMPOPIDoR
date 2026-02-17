import { useRef, useState, useEffect } from "react";
import { useTranslation } from "react-i18next";
import toast from "react-hot-toast";
import DOMPurify from "dompurify";
import Swal from "sweetalert2";
import { Button } from "react-bootstrap";
import { format } from "date-fns";
import { fr, enGB } from "date-fns/locale";
import { BiEdit } from "react-icons/bi";
import { FaTrash } from "react-icons/fa6";
import Global from "../context/GlobalContext.jsx";
import EditorComment from "../WritePlan/EditorComment.jsx";
import CustomSpinner from "./CustomSpinner.jsx";
import CustomError from "./CustomError.jsx";
import { comments as commentsService } from "../../services/index.js";
import {
  NavBodyText,
  ScrollNav,
  CommentsCard,
} from "../WritePlan/styles/CommentModalStyles.jsx";
import "../../i18n.js";
import swalUtils from "../../utils/swalUtils.js";

const locales = { fr, en: enGB };

function CommentList({
  answerId,
  researchOutputId,
  planId,
  questionId,
  userId,
  commentable,
  inModal = false,
  setAnswer,
  setCommentsNumber,
}) {
  const { t, i18n } = useTranslation();
  const editorContentRef = useRef(null);
  const [text, setText] = useState(null);
  const [comments, setComments] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [isUpdate, setIsUpdate] = useState(false);
  const [comment, setComment] = useState(null);

  /**
   * "updateParentText" is a function that takes in a parameter called "updatedText" and then sets the value of "editorContentRef.current" to
   * "updatedText".
   */
  const updateParentText = (updatedText) => {
    editorContentRef.current = updatedText;
  };

  /**
   * When the delete button is clicked, prevent the default action, stop the event from propagating,
   *  delete the item from the list, and set the new list as
   * the data.
   */
  const handleDelete = (e, id) => {
    e.preventDefault();
    e.stopPropagation();

    Swal.fire(swalUtils.defaultConfirmConfig(t)).then((result) => {
      if (result.isConfirmed) {
        commentsService
          .archive(id, {
            archived_by: userId,
          })
          .then(() => {
            const index = comments.findIndex((el) => el.id === id);

            if (!index < 0) {
              Swal.fire(swalUtils.defaultDeleteErrorConfig(t, "comment"));
              return;
            }

            const updatedComments = [...comments];
            updatedComments.splice(index, 1);
            setComments(updatedComments);
            updateTitle(updatedComments);
          })
          .catch(() => {
            Swal.fire(swalUtils.defaultDeleteErrorConfig(t, "comment"));
          });
      }
    });
  };

  /**
   * When the user clicks the update button, the text of the comment is set to the text of
   *  the comment that was clicked, the isUpdate state is set to true,
   * and the comment state is set to the comment that was clicked.
   */
  const handleUpdate = (e, element) => {
    e.preventDefault();
    e.stopPropagation();
    setText(element.text);
    setIsUpdate(true);
    setComment(element);
  };

  const update = async (commentText, commentData) => {
    let response;
    try {
      response = await commentsService.update({
        ...commentData,
        text: commentText,
      });
    } catch {
      return toast.error(t("errorSendComment"));
    }

    if (!response) {
      return toast.error(t("errorSendComment"));
    }

    const { data } = response;

    const updatedComment = {
      ...comment,
      ...data?.note,
    };

    const index = comments.findIndex((item) => item.id === updatedComment.id);
    if (index === -1) {
      return;
    }

    const updatedComments = [...comments];
    updatedComments[index] = updatedComment;

    setComments(updatedComments);
    setIsUpdate(false);

    updateTitle(updatedComments);

    return toast.success(t("commentSuccess"));
  };

  const createComment = async (newText) => {
    const note = {
      answer_id: answerId,
      research_output_id: researchOutputId,
      plan_id: planId,
      question_id: questionId,
      text: newText,
      user_id: userId,
    };

    let response;
    try {
      response = await commentsService.create({ note });
    } catch {
      return toast.error(t("errorSendComment"));
    }

    if (!response) {
      return toast.error(t("errorSendComment"));
    }

    const { data } = response;

    const newNote = {
      ...note,
      ...data?.note,
    };

    setText(null);
    setIsUpdate(false);

    updateTitle([newNote, ...comments]);
    setComments([newNote, ...comments]);

    if (data.answer_created) {
      setAnswer(data.answer);
    }

    return toast.success(t("commentSuccess"));
  };

  const updateTitle = (data) => {
    if (!inModal) {
      const title = document.querySelector(
        `#notes-title-${questionId}-research-output-${researchOutputId}`,
      );
      if (title) {
        title.innerText = `${t("comments")} (${(data || comments).length || 0})`;
      }
    }
  };

  /**
   * I'm trying to update the state of the component with the new data.
   */
  const handleSave = async (e) => {
    e.preventDefault();
    e.stopPropagation();

    const newText = editorContentRef.current;

    if (!newText || newText.length <= 0) {
      return toast.error(t("invalidComment"));
    }

    setText("");

    return isUpdate ? update(newText, comment) : createComment(newText);
  };

  /**
   * USE EFFECTS
   */

  useEffect(() => {
    commentsService
      .get(answerId)
      .then(({ data }) => {
        setComments(data?.notes || []);
      })
      .catch((error) =>
        setError({
          code: error?.response?.status,
          message: error?.response?.statusText,
          error: error?.response?.data?.message || "",
          home: false,
        }),
      )
      .finally(() => setLoading(false));
  }, [answerId]);

  useEffect(() => {
    updateTitle(comments || []);
    if (setCommentsNumber) {
      setCommentsNumber(comments.length || 0);
    }
  }, [comments]);

  /**
   * RENDERING
   */

  return (
    <Global>
      {loading && <CustomSpinner />}
      {!loading && error && <CustomError error={error} />}
      {!loading && !error && comments && (
        <div>
          {comments.length === 0 && (
            <NavBodyText>
              <CommentsCard style={{ margin: 0 }}>
                {t("noCommentsAddYourOwn")}
              </CommentsCard>
            </NavBodyText>
          )}
          <ScrollNav>
            {comments.map((comment, idx) => (
              <NavBodyText
                key={idx}
                style={{ border: !inModal ? "1px solid #2C7DAD" : "" }}
              >
                <div
                  style={{ margin: 0, wordWrap: "break-word" }}
                  dangerouslySetInnerHTML={{
                    __html: DOMPurify.sanitize([comment.text]),
                  }}
                />
                <CommentsCard>
                  <div>
                    <strong style={{ fontSize: "17px" }}>
                      {comment.user.surname} {comment.user.firstname}
                    </strong>{" "}
                    {!inModal && <br />}
                    <i>
                      {t("on")}{" "}
                      {format(new Date(comment.created_at), "dd/MM/yyyy", {
                        locale: locales[i18n.resolvedLanguage || "fr"],
                      })}{" "}
                      {t("at")}{" "}
                      {format(new Date(comment.created_at), "HH:mm:ss", {
                        locale: locales[i18n.resolvedLanguage || "fr"],
                      })}
                    </i>
                  </div>
                  {commentable &&
                    Number.parseInt(userId) ===
                      Number.parseInt(comment.user.id) && (
                      <div>
                        <BiEdit
                          size={22}
                          style={{ marginRight: "5px", cursor: "pointer" }}
                          onClick={(e) => handleUpdate(e, comment)}
                        />
                        <FaTrash
                          size={22}
                          style={{ marginLeft: "5px", cursor: "pointer" }}
                          onClick={(e) => handleDelete(e, comment.id)}
                        />
                      </div>
                    )}
                </CommentsCard>
              </NavBodyText>
            ))}
          </ScrollNav>
          {commentable && (
            <>
              <p
                style={{
                  color: inModal ? "var(--dark-blue)" : "",
                  fontWeight: "bold",
                  marginTop: "30px",
                }}
              >
                {t("addComment")}
              </p>
              <EditorComment
                initialValue={text}
                updateParentText={updateParentText}
              />
              {!loading && !error && (
                <div
                  style={{
                    display: "flex",
                    justifyContent: "right",
                    marginTop: "10px",
                  }}
                >
                  <Button variant="primary" onClick={(e) => handleSave(e)}>
                    {t("save")}
                  </Button>
                </div>
              )}
            </>
          )}
        </div>
      )}
    </Global>
  );
}

export default CommentList;
